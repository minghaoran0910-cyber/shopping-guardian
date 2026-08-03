# v1.10.4 发布验收

发布日期：2026-08-03  
Release：[v1.10.4](https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.4)  
发布目标：`43f337beed6226f6c1ac4d977e66a643a5dbd3c9`。

## 本轮内容

- 可选外部价格历史服务：默认关闭；仅在用户主动配置后发送平台和商品 ID，并校验回传身份、标记来源与本机记录去重。
- 购买建议继续以已确认的已有物品、偏好与可追溯价格证据为前提；没有可靠价格历史时明确显示本机记录范围。
- 消费人格分享卡接入系统分享入口，并保留图片保存降级路径。
- 修复消费人格保存后的异步刷新异常。

## 验证结果

- `dart analyze lib test integration_test tool`：通过，0 个 issue。
- `flutter test --exclude-tags=integration`：通过。
- Android 模拟器（`shopping_guardian_api36`）：通知调度/送达/取消集成测试 2/2 通过；淘宝、京东分享链接解析集成测试通过。
- iOS Simulator：已有物品、消费人格保存与分享卡、可选外部历史价格设置已人工验收。
- 补充模拟器集成验收：Android 的安全存储、淘宝/京东分享解析、通知送达与取消均通过；iOS 的安全存储、淘宝/京东分享解析、通知送达与取消均通过。iOS 通知授权弹窗已实际允许后再完成断言。
- 本地 Android Release APK、macOS Release App 与 iOS Simulator App 均验证版本为 `1.10.4+39`。
- macOS 发布 ZIP 压缩包完整性校验通过。
- GitHub Actions 全部通过：Apple [#30798474448](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30798474448)、Android [#30798474411](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30798474411)、Windows [#30798474529](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30798474529)。

## 发布资产

| 文件 | SHA-256 |
| --- | --- |
| `shopping-guardian-android-v1.10.4.apk` | `ad13cb4594db8bcf4d4f1bdc7e89a3b6bbd15cae9ed3cf214c98619fac73ec47` |
| `shopping-guardian-macos-v1.10.4.zip` | `e9beaad22fcbe4b0d2589d2302b04addc7a73e20fc5f73f653b9ec6d95411f3d` |

## 已知边界

- 外部历史价格服务是用户自建或自行选择的可选服务；未配置时只展示本机开始记录后的价格证据。
- macOS 与 Windows 的开发者签名、iOS TestFlight 和 Android/iPhone 真机辅助功能验收，仍需要项目所有者提供证书、账号或真机，详见 `ROADMAP.md` 和 `DISTRIBUTION.md`。
