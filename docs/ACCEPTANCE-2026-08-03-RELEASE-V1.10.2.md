# v1.10.2 GitHub Release 验收

验收日期：2026-08-03  
发布地址：https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.2  
源码提交：`bdf0882a448b5fedd0409ac0da913c20dfeb6340`

## 结论

GitHub Release `v1.10.2` 已发布并成为 Latest。Android、macOS、Windows 三个安装包及其 SHA-256 文件均为 uploaded；GitHub 计算的三个安装包摘要与本地摘要一致。

本版完成本机价格历史曲线与“先涨后降”提示、分析前显式选择相关现有物品、关系判断缺失时禁止直接购买，以及消费人格系统分享。

## 自动化与构建

- 静态分析：0 问题。
- 完整测试：首轮发现应用版本常量未同步；修复后 217/217 通过。
- Android run `30781746149`：成功，包含 analyze、test、Release 和 OCR/R8 门禁。
- Apple run `30781746163`：成功，包含完整测试、macOS Release 和 iOS Simulator。
- Windows run `30781746174`：成功，包含 analyze、217 项测试、Release、ZIP 和 artifact。
- Android 包内：`versionName=1.10.2`、`versionCode=37`；APK Signature Scheme v2、RSA 4096、1 位签名者。
- macOS 与 iOS Simulator 包内：`CFBundleShortVersionString=1.10.2`、`CFBundleVersion=37`。
- macOS、Windows ZIP 完整解压检查通过。

## 线上资产

| 资产 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `shopping-guardian-android-v1.10.2.apk` | 96,192,892 | `365fc3731b7d9319433022d5d70cbc7c8c01f866072aaddc638833247b234fc1` |
| `shopping-guardian-macos-v1.10.2.zip` | 23,366,860 | `e329f190d9ffe3ea44136ae65cfb0d5e9d8d06053dfa225cff9f85928079f0e4` |
| `shopping-guardian-windows-v1.10.2.zip` | 15,150,282 | `87afe605357458559ed75e7e62d927650b3cb5c0f55e9b91e8b9f2e05985362e` |

## 发布边界

- “本机 30 天低价”只代表本机开始监测后的可信记录，不是全网多年历史低价。
- macOS 包仍未使用 Developer ID 签名、未公证。
- Windows 包仍未使用受信任代码签名证书。
- iOS 仍采用源码自签，不提供通用 IPA。
- A11Y-03 仍需 Android 与 iPhone 各一份真机通过记录。
