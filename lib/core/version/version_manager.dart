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
    final match = RegExp(
            r'Flutter_APP_(V\d+\.\d+\.\d+\(\d{4}-\d{2}-\d{2}\)(?:\.[df]\d+)?)')
        .firstMatch(versionString);
    return match?.group(1) ?? versionString;
  }

  /// 버전 문자열에서 기본 버전 정보 (예: V1.0.0(2025-01-01))를 추출합니다.
  /// 채널 정보(.f1, .d1 등)가 있을 경우 이를 제외합니다.
  String get getFormattedBaseVersion {
    final RegExp baseVersionRegex =
        RegExp(r'Flutter_APP_(V\d+\.\d+\.\d+\(\d{4}-\d{2}-\d{2}\))');
    final match = baseVersionRegex.firstMatch(versionString);
    return match?.group(1) ?? versionString;
  }

  // 채널 우선순위 정의 (f > null(안정) > d)
  static int _getChannelPriority(String? channel) {
    if (channel == 'f') return 2; // f가 가장 높음
    if (channel == null) return 1; // 안정 버전 (null)
    if (channel == 'd') return 0; // d가 가장 낮음
    return -1; // 알 수 없는 채널
  }

  // 업데이트 가능 여부 확인
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    final RegExp versionRegex = RegExp(
        r'Flutter_APP_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)(?:\.([df])(\d+))?');

    final currentMatch = versionRegex.firstMatch(currentVersion);
    final latestMatch = versionRegex.firstMatch(latestVersion);

    if (currentMatch == null || latestMatch == null) {
      return false;
    }

    final currentVersionNumber = currentMatch.group(1)!;
    final currentDate = DateFormat('yyyy-MM-dd').parse(currentMatch.group(2)!);
    final currentChannel = currentMatch.group(3);
    final currentChannelNumber = currentMatch.group(4) != null
        ? int.parse(currentMatch.group(4)!)
        : null;

    final latestVersionNumber = latestMatch.group(1)!;
    final latestDate = DateFormat('yyyy-MM-dd').parse(latestMatch.group(2)!);
    final latestChannel = latestMatch.group(3);
    final latestChannelNumber =
        latestMatch.group(4) != null ? int.parse(latestMatch.group(4)!) : null;

    // 1. 버전 번호 비교 (주요버전.마이너버전.패치버전)
    final List<String> currentParts = currentVersionNumber.split('.');
    final List<String> latestParts = latestVersionNumber.split('.');

    for (int i = 0; i < 3; i++) {
      int current = int.parse(currentParts[i]);
      int latest = int.parse(latestParts[i]);

      if (current != latest) {
        return current < latest; // 최신 버전 번호가 더 높으면 업데이트 필요
      }
    }

    // 2. 버전 번호가 같은 경우, 날짜 비교
    if (latestDate.isAfter(currentDate)) {
      return true; // 최신 버전의 날짜가 더 늦으면 업데이트 필요
    }
    if (currentDate.isAfter(latestDate)) {
      return false; // 현재 버전의 날짜가 더 늦으면 업데이트 불필요
    }

    // 3. 버전 번호와 날짜가 모두 같은 경우, 채널 우선순위 비교
    final currentPriority = _getChannelPriority(currentChannel);
    final latestPriority = _getChannelPriority(latestChannel);

    if (currentPriority != latestPriority) {
      return latestPriority > currentPriority; // 최신 채널 우선순위가 높으면 업데이트 필요
    }

    // 4. 버전 번호, 날짜, 채널 우선순위가 모두 같은 경우, 채널 번호 비교 (개발 버전만 해당)
    if (currentChannelNumber != null && latestChannelNumber != null) {
      // 둘 다 개발 버전인 경우 (d 또는 f)이며, 채널 번호가 있는 경우
      if (currentChannelNumber != latestChannelNumber) {
        return latestChannelNumber >
            currentChannelNumber; // 최신 채널 번호가 높으면 업데이트 필요
      }
    }

    // 모든 조건이 동일하면 업데이트 불필요
    return false;
  }
}
