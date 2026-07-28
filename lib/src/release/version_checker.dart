import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_version.dart';

class ReleaseInformation {
  const ReleaseInformation({
    required this.currentVersion,
    required this.latestVersion,
    required this.notes,
    required this.url,
  });

  final String currentVersion;
  final String latestVersion;
  final String notes;
  final Uri url;

  bool get updateAvailable =>
      _parts(latestVersion).compareTo(_parts(currentVersion)) > 0;

  static _VersionParts _parts(String value) {
    final numbers = value
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('.')
        .map(
          (part) => int.tryParse(RegExp(r'^\d+').stringMatch(part) ?? '0') ?? 0,
        )
        .toList();
    return _VersionParts(
      numbers.elementAtOrNull(0) ?? 0,
      numbers.elementAtOrNull(1) ?? 0,
      numbers.elementAtOrNull(2) ?? 0,
    );
  }
}

class _VersionParts implements Comparable<_VersionParts> {
  const _VersionParts(this.major, this.minor, this.patch);
  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(_VersionParts other) {
    final majorResult = major.compareTo(other.major);
    if (majorResult != 0) return majorResult;
    final minorResult = minor.compareTo(other.minor);
    if (minorResult != 0) return minorResult;
    return patch.compareTo(other.patch);
  }
}

class VersionChecker {
  const VersionChecker({this.client});

  final http.Client? client;

  Future<ReleaseInformation> check() async {
    final requestClient = client ?? http.Client();
    try {
      final response = await requestClient
          .get(
            Uri.parse(
              'https://api.github.com/repos/minghaoran0910-cyber/shopping-guardian/releases/latest',
            ),
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw const VersionCheckException('暂时无法读取 GitHub 版本信息');
      }
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final tag = '${data['tag_name'] ?? ''}'.trim();
      final url = Uri.tryParse('${data['html_url'] ?? ''}');
      if (tag.isEmpty || url == null || url.host != 'github.com') {
        throw const VersionCheckException('GitHub 返回的版本信息不完整');
      }
      return ReleaseInformation(
        currentVersion: AppVersion.current,
        latestVersion: tag.replaceFirst(RegExp(r'^[vV]'), ''),
        notes: '${data['body'] ?? ''}'.trim(),
        url: url,
      );
    } on VersionCheckException {
      rethrow;
    } on Object {
      throw const VersionCheckException('网络不可用，请稍后再试');
    } finally {
      if (client == null) requestClient.close();
    }
  }
}

class VersionCheckException implements Exception {
  const VersionCheckException(this.message);
  final String message;

  @override
  String toString() => message;
}
