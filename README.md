# 购物守护者

一个本地运行的消费决策工具。

把想买的商品链接、描述或截图放进来，应用会结合预算、消费规则和过往记录，调用你自己的模型服务给出建议。商品、预算和历史记录默认只保存在设备上。

## 当前进度

项目处于早期开发阶段。macOS 版本已经可以运行，Android 和 iOS 使用同一套 Flutter 代码，后续逐步适配。

目前已有：

- 商品链接、文字和手动录入界面
- 月度预算概览
- 稍后再看、记录和个人习惯页面
- OpenAI-compatible 模型配置界面
- 浅色、深色和跟随系统主题
- 中文与英文界面
- 本地设置持久化

模型调用、截图 OCR、数据库和提醒功能还在开发中。

## 运行

环境要求：

- Flutter 3.44 或更新版本
- macOS 开发需要完整 Xcode
- Android 开发需要 Android Studio 和 Android SDK
- iOS 插件开发需要 CocoaPods

```bash
flutter pub get
flutter run -d macos
```

检查代码：

```bash
dart analyze lib test
flutter test
```

## 文档

- [MRD](购物守护者-MRD-v0.2.md)
- [PRD](购物守护者-PRD-v0.1-macOS.md)
- [产品上下文](PRODUCT.md)
- [设计规范](DESIGN.md)

## 数据与隐私

- 不需要注册账号
- API Key 计划使用系统安全存储
- 模型请求将直接发送到用户填写的服务地址
- 导出数据不会包含 API Key
- 项目方不提供中转模型服务

## License

Apache License 2.0
