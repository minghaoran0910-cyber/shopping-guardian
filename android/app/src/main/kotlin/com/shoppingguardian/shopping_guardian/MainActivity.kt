package com.shoppingguardian.shopping_guardian

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.app.NotificationManager
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var initialText: String? = null
    private var ocrResult: MethodChannel.Result? = null
    private var notificationPermissionResult: MethodChannel.Result? = null
    private var pendingNotification: NotificationRequest? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initialText = sharedText(intent)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "shopping_guardian/shared_text",
        ).also { methodChannel ->
            methodChannel.setMethodCallHandler { call, result ->
                if (call.method == "getInitialText") {
                    result.success(initialText)
                    initialText = null
                } else {
                    result.notImplemented()
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "shopping_guardian/cart_ocr",
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickAndRecognize") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (ocrResult != null) {
                result.error("ocr_busy", "已经在读取一张图片。", null)
                return@setMethodCallHandler
            }
            ocrResult = result
            val picker = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "image/*"
            }
            startActivityForResult(picker, OCR_PICK_REQUEST)
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "shopping_guardian/notifications",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "schedule" -> {
                    val request = NotificationRequest(
                        id = call.argument<String>("id").orEmpty(),
                        title = call.argument<String>("title").orEmpty(),
                        timestamp = call.argument<Number>("timestamp")?.toLong() ?: 0L,
                    )
                    if (request.id.isEmpty() || request.timestamp <= 0L) {
                        result.error("invalid_notification", "提醒信息不完整。", null)
                    } else if (
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                        checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                            PackageManager.PERMISSION_GRANTED
                    ) {
                        if (notificationPermissionResult != null) {
                            result.error("permission_busy", "正在等待通知权限。", null)
                        } else {
                            notificationPermissionResult = result
                            pendingNotification = request
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                NOTIFICATION_PERMISSION_REQUEST,
                            )
                        }
                    } else {
                        result.success(scheduleNotification(request))
                    }
                }
                "cancel" -> {
                    val id = call.argument<String>("id").orEmpty()
                    cancelNotification(id)
                    result.success(null)
                }
                "isDelivered" -> {
                    val id = call.argument<String>("id").orEmpty()
                    val manager = getSystemService(NotificationManager::class.java)
                    result.success(
                        manager?.activeNotifications?.any { it.id == id.hashCode() } == true,
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        sharedText(intent)?.let { text ->
            channel?.invokeMethod("onSharedText", text)
        }
    }

    @Deprecated("Deprecated in Android SDK; retained for API 24 compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != OCR_PICK_REQUEST) return
        val pending = ocrResult ?: return
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pending.success(emptyList<String>())
            ocrResult = null
            return
        }
        val image = try {
            InputImage.fromFilePath(this, uri)
        } catch (error: Exception) {
            pending.error("image_read_failed", error.localizedMessage, null)
            ocrResult = null
            return
        }
        val recognizer = TextRecognition.getClient(
            ChineseTextRecognizerOptions.Builder().build(),
        )
        recognizer.process(image)
            .addOnSuccessListener { text ->
                val lines = text.textBlocks.flatMap { block ->
                    block.lines.map { line -> line.text }
                }
                pending.success(lines)
            }
            .addOnFailureListener { error ->
                pending.error("ocr_failed", error.localizedMessage, null)
            }
            .addOnCompleteListener {
                recognizer.close()
                ocrResult = null
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST) return
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        val request = pendingNotification
        notificationPermissionResult?.success(
            granted && request != null && scheduleNotification(request),
        )
        notificationPermissionResult = null
        pendingNotification = null
    }

    private fun scheduleNotification(request: NotificationRequest): Boolean {
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return false
        val pendingIntent = notificationPendingIntent(request, PendingIntent.FLAG_UPDATE_CURRENT)
        val triggerAt = maxOf(request.timestamp, System.currentTimeMillis() + 1_000L)
        alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        return true
    }

    private fun cancelNotification(id: String) {
        if (id.isEmpty()) return
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return
        val request = NotificationRequest(id, "", 0L)
        val intent = notificationPendingIntent(request, PendingIntent.FLAG_UPDATE_CURRENT)
        alarmManager.cancel(intent)
        intent.cancel()
        getSystemService(NotificationManager::class.java)?.cancel(id.hashCode())
    }

    private fun notificationPendingIntent(
        request: NotificationRequest,
        flag: Int,
    ): PendingIntent = PendingIntent.getBroadcast(
        this,
        request.id.hashCode(),
        Intent(this, CooldownNotificationReceiver::class.java).apply {
            putExtra("decision_id", request.id)
            putExtra("title", request.title)
        },
        flag or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun sharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") {
            return null
        }
        return intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val OCR_PICK_REQUEST = 4201
        private const val NOTIFICATION_PERMISSION_REQUEST = 4202
    }

    private data class NotificationRequest(
        val id: String,
        val title: String,
        val timestamp: Long,
    )
}
