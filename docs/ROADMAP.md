# 购物守护者待做事项

本清单以“稳定、可恢复、可解释”优先，不以页面数量为目标。每项都遵循：实现 → 自审 → 定向测试 → 修复 → 全量测试 → 构建 → Git 同步。

## 当前进行中

- [x] UI-01 将主题收敛为白色浅色主题和中性暗黑主题
- [x] UI-02 更新 Golden 基线并检查浅色/暗色对比度
- [x] DATA-01 实现真正的“清除全部数据”
- [x] DATA-02 清除时取消全部应用通知
- [x] DATA-03 增加清除范围测试和重启测试

## P0：稳定 1.0

- [x] DATA-04 选择并接入 SQLite/Drift
- [x] DATA-05 迁移现有 SharedPreferences 决策、预算和规则
- [x] DATA-06 增加 Schema 版本、事务和损坏记录隔离
- [x] DATA-07 实现 JSON 数据导入
- [x] DATA-08 支持导入预览、覆盖/合并和失败回滚
- [ ] MODEL-01 Endpoint 支持标准路径与完整自定义地址
- [ ] MODEL-02 `response_format` 可配置
- [ ] MODEL-03 增加 Ollama 和常见兼容服务预设
- [ ] MODEL-04 处理 429、5xx 和有限退避
- [ ] PRIVACY-01 重写首次启动与设置页的第三方数据说明
- [ ] PRIVACY-02 分析前展示即将发送的数据摘要
- [ ] PRIVACY-03 说明各平台密钥和业务数据的存储方式

## P1：个人化闭环

- [ ] MEMORY-01 商品分类与标签
- [ ] MEMORY-02 结构化使用频率、满意度和后悔原因
- [ ] MEMORY-03 购买后反馈提醒
- [ ] MEMORY-04 个人物品库
- [ ] MEMORY-05 带证据的候选规律
- [ ] MEMORY-06 规律确认、编辑、忽略和删除
- [ ] MEMORY-07 历史、物品和规律的引用追溯
- [ ] IMPORT-01 淘宝/京东 HTML fixture 测试集
- [ ] IMPORT-02 自动解析失败的分级降级策略
- [ ] IMPORT-03 可导出的脱敏诊断
- [ ] ARCH-01 拆分 `home_shell.dart`
- [ ] CI-01 Android CI
- [ ] CI-02 macOS 与 iOS Simulator CI

## P2：体验与分发

- [ ] UX-01 首次配置向导
- [ ] UX-02 导入完整度和人工核对状态
- [ ] UX-03 技术错误转为可执行提示
- [ ] A11Y-01 200% 字号与文字溢出验收
- [ ] A11Y-02 键盘导航验收
- [ ] A11Y-03 TalkBack 与 VoiceOver 验收
- [ ] RELEASE-01 macOS 签名与公证
- [ ] RELEASE-02 Windows 代码签名
- [ ] RELEASE-03 iOS TestFlight 或维持源码自签的长期决策
- [ ] RELEASE-04 版本检查与升级说明
