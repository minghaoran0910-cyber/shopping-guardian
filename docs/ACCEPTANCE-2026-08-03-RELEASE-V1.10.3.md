# v1.10.3 发布验收

发布日期：2026-08-03  
Release：[v1.10.3](https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.3)  
发布目标：`43fe50f06cd23bc6d64b2f1f497e86a3980dc83a`

## 验证结果

- `dart analyze lib test integration_test tool`：通过（0 个 issue）。
- `flutter test --exclude-tags=integration`：218/218 通过。
- 本地 Android Release APK、macOS Release App、iOS Simulator App 均验证为 `1.10.3+38`。
- Android APK 通过 APK Signature Scheme v2 校验，签名主体为 `CN=Shopping Guardian, O=Shopping Guardian, C=CN`。
- macOS、Windows 发布 ZIP 均通过压缩包完整性测试。
- GitHub Actions 全部通过：Apple [#30789940550](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30789940550)、Android [#30789940467](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30789940467)、Windows [#30789940454](https://github.com/minghaoran0910-cyber/shopping-guardian/actions/runs/30789940454)。

## 发布资产

| 文件 | 大小 | SHA-256 |
| --- | ---: | --- |
| `shopping-guardian-android-v1.10.3.apk` | 96,209,276 B | `d1fbdbe2b538d99a3620a9dcaa3125c93acfe80e538deae2c96f293977a0ebe2` |
| `shopping-guardian-macos-v1.10.3.zip` | 23,376,269 B | `cc47665d4544636930042ce585e0c41ae42f26e263f4a926d41d92bb4a1dc725` |
| `shopping-guardian-windows-v1.10.3.zip` | 15,159,084 B | `659a8c609bb8a5a4aa30eb60122ff46c5ece348516920e7f007fc9ac86ffeb6a` |

每个主资产均附带同名 `.sha256` 文件，GitHub Release 的服务端 digest 已逐项复核。

## 已知边界

- 历史低价仍是本机快照；外部可选价格提供器（ROADMAP `PRICE-04`）尚未接入。
- macOS 与 Windows 包未进行开发者签名；iOS 仅提供 Simulator 构建，没有对外分发的 IPA。
