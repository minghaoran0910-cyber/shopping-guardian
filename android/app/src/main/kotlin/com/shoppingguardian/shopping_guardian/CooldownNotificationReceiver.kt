package com.shoppingguardian.shopping_guardian

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class CooldownNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "购物提醒",
                    NotificationManager.IMPORTANCE_DEFAULT,
                ).apply {
                    description = "目标价、冷静期和购买后回访提醒"
                },
            )
        }
        val openApp = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val itemName = intent.getStringExtra("title").orEmpty()
        val kind = intent.getStringExtra("kind").orEmpty()
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context).setPriority(Notification.PRIORITY_DEFAULT)
        }
        val heading = when (kind) {
            "price" -> "达到目标价"
            "feedback" -> "用了一周，感觉怎么样？"
            else -> "冷静期结束了"
        }
        val message = when (kind) {
            "price" -> if (itemName.isEmpty()) "价格合适了，可以考虑下单。" else "$itemName，可以考虑下单。"
            "feedback" -> if (itemName.isEmpty()) "回来记录一下实际体验。" else itemName
            else -> if (itemName.isEmpty()) "现在还想买吗？" else "再看看：$itemName"
        }
        val notification = builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(heading)
            .setContentText(message)
            .setCategory(Notification.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(openApp)
            .build()
        val decisionId = intent.getStringExtra("decision_id").orEmpty()
        manager.notify(decisionId.hashCode(), notification)
    }

    companion object {
        private const val CHANNEL_ID = "cooldown_reminders"
    }
}
