# v1.10.0 GitHub Release 验收

验收日期：2026-07-30  
发布地址：https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.0  
源码提交：`9d06623b1d8c3f0caf5e164bc72d095e69a78bc8`

## 结论

GitHub Release `v1.10.0` 已发布并标记为 Latest。Android、macOS、Windows 三个安装包及各自的 SHA-256 文件均已上传；线上资产摘要与本地验收摘要一致。

iOS 继续采用源码自签策略，不提供无法验证来源的通用 IPA。macOS 与 Windows 构建当前仍未获得受信任签名，发布说明已明确首次启动和 SmartScreen 风险，不把未签名构建描述为正式签名包。

## 构建与验证证据

- Android APK
  - 包内 `versionName=1.10.0`
  - 包内 `versionCode=35`
  - `apksigner verify`：v2 签名通过，签名者数量 1
  - ML Kit / R8 release 校验通过
- macOS ZIP
  - 应用内 `CFBundleShortVersionString=1.10.0`
  - 应用内 `CFBundleVersion=35`
  - `unzip -t` 无错误
- Windows ZIP
  - GitHub Actions Windows build run `30521109338` 成功
  - 构建源码为 `9d06623b1d8c3f0caf5e164bc72d095e69a78bc8`
  - `unzip -t` 无错误
- 数据备份改动所在提交 `a084c80fd3f4425c192926487416ec5fd1007abc`
  - Android build run `30520820617` 成功
  - Windows build run `30520820655` 成功
  - Apple builds run `30520820656` 成功

## 线上资产

| 资产 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `shopping-guardian-android-v1.10.0.apk` | 96,027,590 | `cb21e4b37d0001deb5774bd26cafc313d42a979778c97de906e57c77993dda20` |
| `shopping-guardian-macos-v1.10.0.zip` | 23,230,085 | `d9ad690f5643787ab134a9d3c01b192ab8314eae5d3bb1009028179dfc49d17c` |
| `shopping-guardian-windows-v1.10.0.zip` | 15,014,189 | `82046936bb7c58f70ba462f9987e8d069af75bb127fa397674866b2f30998771` |

每个安装包旁均提供只引用相对文件名的 `.sha256` 文件，可将两者放在同一目录后执行：

```bash
shasum -a 256 -c <校验文件名>
```

## 已知边界

- 价格提醒依赖商品页面仍可访问、解析服务可用，以及系统允许通知和后台执行；它不是电商平台官方实时行情。
- macOS 包未使用 Developer ID 签名、未公证。
- Windows 包未使用受信任代码签名证书。
- TalkBack 与 VoiceOver 的最终可访问性验收仍需要 Android 和 iPhone 真机记录，模拟器结果不能替代。
