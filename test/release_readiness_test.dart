import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('真机无障碍清单覆盖两个平台和四段核心流程', () {
    final checklist = File(
      'docs/ACCESSIBILITY-ACCEPTANCE.md',
    ).readAsStringSync();

    expect(checklist, contains('TalkBack'));
    expect(checklist, contains('VoiceOver'));
    for (final prefix in ['A', 'B', 'C', 'D']) {
      for (var index = 1; index <= 5; index++) {
        expect(
          checklist,
          contains('$prefix${index.toString().padLeft(2, '0')}'),
          reason: '缺少 $prefix${index.toString().padLeft(2, '0')} 验收项',
        );
      }
    }
    expect(checklist, contains('不得用模拟器结果代替'));
    expect(checklist, contains('请勿包含 API Key'));
  });

  test('macOS 正式工作流要求凭据并验证公证结果', () {
    final workflow = File(
      '.github/workflows/macos-signed-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, isNot(contains('push:')));
    expect(workflow, contains('Require signing credentials'));
    expect(workflow, contains('Release.entitlements'));
    expect(workflow, contains('notarytool submit'));
    expect(workflow, contains('stapler validate'));
    expect(workflow, contains('spctl --assess'));
    expect(workflow, contains('if: always()'));
  });

  test('Windows 正式工作流签署并双重验证所有二进制', () {
    final workflow = File(
      '.github/workflows/windows-signed-release.yml',
    ).readAsStringSync();

    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, isNot(contains('push:')));
    expect(workflow, contains('Require signing credentials'));
    expect(workflow, contains('signtool.exe'));
    expect(workflow, contains('verify /pa /all /v'));
    expect(workflow, contains('Get-AuthenticodeSignature'));
    expect(workflow, contains('if: always()'));
  });

  test('Android release 保留 ML Kit 反射注册器的构造函数', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final rules = File('android/app/proguard-rules.pro').readAsStringSync();
    final workflow = File(
      '.github/workflows/android-build.yml',
    ).readAsStringSync();

    expect(gradle, contains('"proguard-rules.pro"'));
    expect(
      rules,
      contains('implements com.google.firebase.components.ComponentRegistrar'),
    );
    expect(rules, contains('public <init>();'));
    expect(workflow, contains('bash tool/check_android_mlkit_r8.sh'));
  });
}
