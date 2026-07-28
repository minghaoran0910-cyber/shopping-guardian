import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/release/app_version.dart';
import 'package:shopping_guardian/src/release/version_checker.dart';

void main() {
  test('当前版本常量与 pubspec 保持一致', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    expect(pubspec, contains('version: ${AppVersion.current}+'));
  });

  test('读取 GitHub 最新版本和升级说明', () async {
    final checker = VersionChecker(
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'tag_name': 'v1.9.0',
              'body': '修复导入问题',
              'html_url':
                  'https://github.com/minghaoran0910-cyber/shopping-guardian/releases/tag/v1.9.0',
            }),
          ),
          200,
        ),
      ),
    );
    final release = await checker.check();
    expect(release.latestVersion, '1.9.0');
    expect(release.updateAvailable, isTrue);
    expect(release.notes, '修复导入问题');
  });

  test('拒绝非 GitHub 下载地址', () async {
    final checker = VersionChecker(
      client: MockClient(
        (_) async => http.Response(
          '{"tag_name":"v2.0.0","html_url":"https://evil.example/app"}',
          200,
        ),
      ),
    );
    expect(checker.check, throwsA(isA<VersionCheckException>()));
  });
}
