# 发布凭据最小权限审查

## 风险

旧版 macOS 与 Windows 签名工作流把证书和密码放在 Job 级环境变量中，并允许手动输入任意 revision。被选中 revision 的依赖解析、测试或构建逻辑能够读取这些变量，不符合发布密钥最小权限原则。

## 修复

- checkout 使用完整历史，并在任何构建命令前验证 `HEAD` 可从 `origin/main` 到达。
- 任意分支、Pull Request 提交或其他不在 main 历史中的 revision 会立即失败。
- macOS 凭据只注入凭据检查、Developer ID 导入、签名和公证步骤。
- Windows 凭据只注入凭据检查与 PFX 导入步骤；后续签名只使用证书指纹。
- 分析、测试和 Flutter 构建步骤不再拥有发布密钥环境变量。
- 无密钥 CI 会检查 Job 级环境变量、main 历史验证顺序和允许的 Secret 名称，阻止后续回归。

## 尚未完成

本修复只能证明工作流静态安全边界。RELEASE-01 与 RELEASE-02 仍需真实 Developer ID / 公证凭据和受信任 Windows 证书运行成功后才能完成。
