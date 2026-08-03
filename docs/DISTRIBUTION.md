# 分发与签名决策

更新日期：2026-07-30

## 当前策略

- 当前 Latest Release：[`v1.10.3`](https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.10.3)。
- Android：GitHub Release 提供 APK；发布前校验包内版本、签名和 SHA-256。
- macOS：当前提供未公证 ZIP，并在下载说明中明确系统首次打开方式。
- Windows：当前提供未签名便携 ZIP，下载页明确 SmartScreen 提示。
- iOS：维持源码自签，不提供无法验证来源的通用 IPA。

## 为什么 iOS 暂时维持源码自签

项目目前没有可用于公开分发的 Apple Developer Program 团队、Developer ID 和 App Store Connect 权限。模拟器构建成功只能证明代码可编译，不能替代签名、设备安装和 TestFlight 审核。

在具备以下条件前，不创建“正式 IPA”或宣称支持 TestFlight：

1. 项目所有者加入 Apple Developer Program。
2. 确定稳定的 Bundle ID、签名团队和隐私信息。
3. 在真实 iPhone 上完成分享扩展、通知、密钥存储和 VoiceOver 验收。
4. TestFlight 构建由项目所有者账号上传并验证。

## macOS 公证的完成条件

1. 提供 Developer ID Application 证书。
2. 提供可用于 `notarytool` 的 App Store Connect API Key 或受控凭据。
3. CI 中凭据只以加密 Secret 注入，完成后删除临时钥匙串。
4. 对 ZIP 内应用执行签名检查、`stapler validate` 和 Gatekeeper 验证。

仓库已提供手动工作流 `macOS signed release`。配置以下 GitHub Actions Secrets 后，输入待发布的 tag 或提交运行：

- `MACOS_CERTIFICATE_BASE64`
- `MACOS_CERTIFICATE_PASSWORD`
- `MACOS_SIGNING_IDENTITY`
- `APPLE_API_KEY_BASE64`
- `APPLE_API_KEY_ID`
- `APPLE_API_ISSUER_ID`

工作流会重新分析、测试和构建，再依次执行 Developer ID 签名、公证、装订、Gatekeeper 验证并生成 SHA-256。缺少任何凭据时会立即失败，不会产出看似正式的未签名包。

发布密钥只注入凭据检查、证书导入和签名/公证步骤，不会暴露给依赖解析、测试或构建命令。手动输入的 revision 必须是 `origin/main` 历史中可验证的提交；任意分支或外部提交会在接触发布凭据前被拒绝。

## Windows 代码签名的完成条件

1. 提供受信任 CA 颁发的代码签名证书或云签名服务。
2. 密钥不进入仓库或普通 artifact。
3. 对 EXE 和必要 DLL 签名，并用 `Get-AuthenticodeSignature` 验证。

仓库已提供手动工作流 `Windows signed release`。配置 `WINDOWS_CERTIFICATE_BASE64` 和 `WINDOWS_CERTIFICATE_PASSWORD` 后，输入待发布的 tag 或提交运行。工作流会签署 release 目录内全部 EXE/DLL，同时用 `signtool verify` 和 `Get-AuthenticodeSignature` 双重验证，然后生成带 SHA-256 的便携 ZIP。

Windows 工作流同样只接受 `origin/main` 历史中的提交，证书只对凭据检查与证书导入步骤可见，Flutter 依赖解析、测试和构建阶段无法读取证书内容或密码。

没有证书时，项目继续发布可复现、带哈希的未签名构建，不使用自签证书伪装成受信任分发。
