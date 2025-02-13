import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'version_info.dart';

// 버전 관리 클래스
class Version {
  final String versionString;
  final Color color;

  const Version({
    required this.versionString,
    required this.color,
  });

  factory Version.parse(String versionString) {
    return Version(
      versionString: versionString,
      color: Colors.blue,
    );
  }

  factory Version.fromVersionInfo(VersionInfo info) {
    return Version(
      versionString: info.versionString,
      color: Colors.blue,
    );
  }

  String get formattedVersion => versionString;

  // 업데이트 버전 문자열 추출
  String get updateVersion {
    final match = RegExp(r'Flutter_APP_(V\d+\.\d+\.\d+\(\d{4}-\d{2}-\d{2}\))')
        .firstMatch(versionString);
    return match?.group(1) ?? versionString;
  }

  // 업데이트 가능 여부 확인
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    final currentMatch =
        RegExp(r'Flutter_APP_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)')
            .firstMatch(currentVersion);
    final latestMatch =
        RegExp(r'Flutter_APP_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)')
            .firstMatch(latestVersion);

    if (currentMatch == null || latestMatch == null) {
      return false;
    }

    final currentVersionNumber = currentMatch.group(1);
    final currentDate = DateFormat('yyyy-MM-dd').parse(currentMatch.group(2)!);
    final latestVersionNumber = latestMatch.group(1);
    final latestDate = DateFormat('yyyy-MM-dd').parse(latestMatch.group(2)!);

    if (latestVersionNumber != currentVersionNumber) {
      return latestVersionNumber!.compareTo(currentVersionNumber!) > 0;
    }

    return latestDate.isAfter(currentDate);
  }
}
