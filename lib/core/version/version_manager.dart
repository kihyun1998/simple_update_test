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
    // d1, f1 등을 포함하는 버전 형식을 지원하는 정규식
    final RegExp versionRegex = RegExp(
        r'Flutter_APP_V(\d+\.\d+\.\d+(?:\.[df]\d+)?)\((\d{4}-\d{2}-\d{2})\)');

    final currentMatch = versionRegex.firstMatch(currentVersion);
    final latestMatch = versionRegex.firstMatch(latestVersion);

    if (currentMatch == null || latestMatch == null) {
      return false;
    }

    final currentVersionNumber = currentMatch.group(1)!;
    final currentDate = DateFormat('yyyy-MM-dd').parse(currentMatch.group(2)!);
    final latestVersionNumber = latestMatch.group(1)!;
    final latestDate = DateFormat('yyyy-MM-dd').parse(latestMatch.group(2)!);

    // 버전 번호 분리
    final List<String> currentParts = currentVersionNumber.split('.');
    final List<String> latestParts = latestVersionNumber.split('.');

    // major, minor, patch 비교
    for (int i = 0; i < 3; i++) {
      int current = int.parse(currentParts[i]);
      int latest = int.parse(latestParts[i]);

      if (current != latest) {
        return current < latest;
      }
    }

    // d/f 버전 비교 (있는 경우)
    if (currentParts.length > 3 && latestParts.length > 3) {
      String currentType = currentParts[3][0]; // 'd' 또는 'f'
      String latestType = latestParts[3][0];

      if (currentType != latestType) {
        // d 버전이 f 버전보다 낮은 것으로 처리
        return currentType == 'd' && latestType == 'f';
      }

      // 같은 타입일 경우 숫자 비교
      int currentNum = int.parse(currentParts[3].substring(1));
      int latestNum = int.parse(latestParts[3].substring(1));
      if (currentNum != latestNum) {
        return currentNum < latestNum;
      }
    } else if (latestParts.length > currentParts.length) {
      return true;
    } else if (currentParts.length > latestParts.length) {
      return false;
    }

    // 버전이 완전히 동일한 경우에만 날짜 비교
    return latestDate.isAfter(currentDate);
  }
}
