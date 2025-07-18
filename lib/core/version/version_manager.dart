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

  // 업데이트 버전 문자열 추출 (이전 로직과 동일하게 유지)
  String get updateVersion {
    // Flutter_APP_V1.0.0(2025-01-01).f1 형태도 커버하도록 수정합니다.
    final match = RegExp(
            r'Flutter_APP_(V\d+\.\d+\.\d+\(\d{4}-\d{2}-\d{2}\)(?:\.[df]\d+)?)')
        .firstMatch(versionString);
    return match?.group(1) ?? versionString;
  }

  /// 버전 문자열에서 기본 버전 정보 (예: V1.0.0(2025-01-01))를 추출합니다.
  /// 채널 정보(.f1, .d1 등)가 있을 경우 이를 제외합니다.
  String get getFormattedBaseVersion {
    // Flutter_APP_V로 시작하고 괄호 안의 날짜로 끝나는 부분을 찾습니다.
    // 그 뒤에 .fX 또는 .dX가 올 수도 있지만, 해당 부분은 포함하지 않습니다.
    final RegExp baseVersionRegex =
        RegExp(r'Flutter_APP_(V\d+\.\d+\.\d+\(\d{4}-\d{2}-\d{2}\))');
    final match = baseVersionRegex.firstMatch(versionString);

    // 첫 번째 캡처 그룹이 기본 버전 정보입니다.
    return match?.group(1) ?? versionString; // 일치하는 부분이 없으면 전체 문자열 반환
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
    // 수정된 정규식: V1.0.0(2025-01-01).f1 형식을 지원
    final RegExp versionRegex = RegExp(
        r'Flutter_APP_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)(?:\.([df])(\d+))?');

    final currentMatch = versionRegex.firstMatch(currentVersion);
    final latestMatch = versionRegex.firstMatch(latestVersion);

    if (currentMatch == null || latestMatch == null) {
      // 정규식에 일치하지 않으면 업데이트 여부를 판단할 수 없으므로 false 반환
      return false;
    }

    final currentVersionNumber = currentMatch.group(1)!; // V1.0.0
    final currentDate =
        DateFormat('yyyy-MM-dd').parse(currentMatch.group(2)!); // 2025-01-01
    final currentChannel = currentMatch.group(3); // d 또는 f 또는 null
    final currentChannelNumber = currentMatch.group(4) != null
        ? int.parse(currentMatch.group(4)!)
        : null;

    final latestVersionNumber = latestMatch.group(1)!; // V1.0.0
    final latestDate =
        DateFormat('yyyy-MM-dd').parse(latestMatch.group(2)!); // 2025-01-01
    final latestChannel = latestMatch.group(3); // d 또는 f 또는 null
    final latestChannelNumber =
        latestMatch.group(4) != null ? int.parse(latestMatch.group(4)!) : null;

    final currentPriority = _getChannelPriority(currentChannel);
    final latestPriority = _getChannelPriority(latestChannel);

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

    // 2. 버전 번호가 같은 경우, 채널 우선순위 비교
    if (currentPriority != latestPriority) {
      return latestPriority > currentPriority; // 최신 채널 우선순위가 높으면 업데이트 필요
    }

    // 3. 버전 번호와 채널 우선순위가 모두 같은 경우, 채널 번호 비교 (개발 버전만 해당)
    // 현재는 'd' 또는 'f' 채널만 이 로직을 따름
    if (currentChannel != null && latestChannel != null) {
      if (currentChannelNumber != latestChannelNumber) {
        return latestChannelNumber! >
            currentChannelNumber!; // 최신 채널 번호가 높으면 업데이트 필요
      }
    }

    // 4. 버전 번호, 채널 우선순위, 채널 번호가 모두 같은 경우, 날짜 비교
    return latestDate.isAfter(currentDate); // 최신 버전의 날짜가 더 늦으면 업데이트 필요
  }
}
