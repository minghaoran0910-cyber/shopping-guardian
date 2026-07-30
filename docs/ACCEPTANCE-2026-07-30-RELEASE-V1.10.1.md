# v1.10.1 GitHub Release 验收

验收日期：2026-07-30  
发布地址：https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.1  
源码提交：`f13c92cbc36d37b1609c34780b665a53c3d7d693`

## 结论

GitHub Release `v1.10.1` 已发布并标记为 Latest。Android、macOS、Windows 三个安装包及其 SHA-256 文件均已上传，GitHub 计算出的安装包摘要与本地摘要一致。

本版修复 Android 分享入口焦点、预算输入标签和异步状态播报。它完成了真机读屏验收前的代码检查，但不替代 Android TalkBack 与 iPhone VoiceOver 的 A01–D05 真机验收。

## 自动化与构建

- 静态分析：0 问题。
- 全量测试：207 项通过。
- Android build run `30523173325`：成功。
  - analyze、test、release build、OCR/R8 门禁均通过。
- Windows build run `30523173295`：成功。
  - analyze、test、release build、便携包打包与上传均通过。
- Apple builds run `30523173323`：成功。
- 本地 Android release：
  - 包内 `versionName=1.10.1`
  - 包内 `versionCode=36`
  - APK Signature Scheme v2 验证通过，签名者数量 1
- 本地 iOS Simulator：
  - 包内 `CFBundleShortVersionString=1.10.1`
  - 包内 `CFBundleVersion=36`
- 本地 macOS release：
  - 包内 `CFBundleShortVersionString=1.10.1`
  - 包内 `CFBundleVersion=36`
- macOS 与 Windows ZIP 均通过完整解压检查。

## 线上资产

| 资产 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `shopping-guardian-android-v1.10.1.apk` | 96,027,586 | `cdc1eba936adaeadea56bfdcb366e64d0d39ea0fef860315c261fae1c12d5e85` |
| `shopping-guardian-macos-v1.10.1.zip` | 23,243,854 | `adedbb7652ead551ef80bbf08f1148034db37fb4e7e458abd68276d21fbcd5bf` |
| `shopping-guardian-windows-v1.10.1.zip` | 15,014,335 | `1381ebed7e21de2d5eec1b2b8928a0222510230f827d7801716a38f713d5ae9e` |

## 发布边界

- macOS 包仍未使用 Developer ID 签名、未公证。
- Windows 包仍未使用受信任代码签名证书。
- iOS 仍采用源码自签，不提供通用 IPA。
- A11Y-03 仍需 Android 与 iPhone 各一份真机通过记录。
