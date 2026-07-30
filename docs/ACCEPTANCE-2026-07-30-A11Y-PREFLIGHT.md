# A11Y-03 真机验收前置检查

日期：2026-07-30  
候选版本：1.10.1+36

## 结论

本轮只完成能由代码和自动化证明的前置检查，不把模拟器或 Widget Test 当作 TalkBack/VoiceOver 真机验收。

发现并修复：

1. Android 分享文字进入应用后，商品输入框虽然已填入内容，但没有主动获得焦点。现在共享文字写入后会把焦点移到带有“链接或描述”标签的输入框，减少读屏用户找不到下一步位置的风险。
2. “设置本月预算”对话框的数字输入框只有货币前缀，没有字段标签。现在提供“本月预算 / Monthly budget”标签。
3. 商品读取、模型连接测试、JustOneAPI 连接测试和 AI 分析的进行中状态现在使用 live region，状态文字也随过程更新，便于读屏感知异步状态变化。

## 自动化证据

- `test/accessibility_test.dart`
  - 200% 字号关键页面无溢出。
  - 桌面键盘可建立焦点并切换导航。
  - 主要页面通过标签和 Android 触控尺寸门禁。
  - Android 初始分享文字会进入有标签的商品输入框，且输入框真实获得焦点。
  - 预算输入框的语义子树包含明确标签。
- 无障碍定向测试：5/5 通过。
- 全量测试：207 项通过。
- 静态分析：0 问题。由于 Flutter 3.44.6 analysis server 在当前中文绝对路径上可复现 LSP JSON 截断，使用排除 `.git`、`build` 和 `test/failures` 的同源 ASCII 临时副本执行；代码内容一致。

## 构建证据

- Android release APK 构建通过。
  - 包内 `versionName=1.10.1`
  - 包内 `versionCode=36`
  - ML Kit / R8 反射构造器检查通过
- iOS Simulator debug 构建通过。
  - 包内 `CFBundleShortVersionString=1.10.1`
  - 包内 `CFBundleVersion=36`
- macOS release 构建通过。
  - 包内 `CFBundleShortVersionString=1.10.1`
  - 包内 `CFBundleVersion=36`

## 仍不能自动证明的项目

以下内容必须继续按 `docs/ACCESSIBILITY-ACCEPTANCE.md` 在真实 Android 与 iPhone 上验证：

- 完整滑动浏览顺序和焦点是否自然；
- live region 在 TalkBack 与 VoiceOver 中的实际播报时机；
- 系统照片/文件选择器、分享面板和通知的读屏体验；
- 默认及最大辅助字号下完成 A01–D05 全流程；
- 实际播报是否重复、含糊或遗漏操作结果。

因此本记录不会将路线图中的 A11Y-03 标记为完成。
