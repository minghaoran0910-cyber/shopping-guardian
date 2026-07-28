# 分发与签名决策

更新日期：2026-07-28

## 当前策略

- Android：GitHub Release 提供 APK；正式发布前继续校验签名和 SHA-256。
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

## Windows 代码签名的完成条件

1. 提供受信任 CA 颁发的代码签名证书或云签名服务。
2. 密钥不进入仓库或普通 artifact。
3. 对 EXE 和必要 DLL 签名，并用 `Get-AuthenticodeSignature` 验证。

没有证书时，项目继续发布可复现、带哈希的未签名构建，不使用自签证书伪装成受信任分发。
