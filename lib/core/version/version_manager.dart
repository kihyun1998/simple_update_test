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
    // 버전 형식을 지원하는 정규식
    // d1, f1 등을 포함하는 버전 형식을 지원
    final RegExp versionRegex = RegExp(
        r'Flutter_APP_V(\d+\.\d+\.\d+)(?:\.([df])(\d+))?\((\d{4}-\d{2}-\d{2})\)');

    final currentMatch = versionRegex.firstMatch(currentVersion);
    final latestMatch = versionRegex.firstMatch(latestVersion);

    if (currentMatch == null || latestMatch == null) {
      return false;
    }

    final currentVersionNumber = currentMatch.group(1)!;
    final currentIsStable = currentMatch.group(2) == null; // 안정 버전 여부
    final currentChannel = currentMatch.group(2); // d 또는 f 또는 null
    final currentChannelNumber = currentMatch.group(3) != null
        ? int.parse(currentMatch.group(3)!)
        : null;
    final currentDate = DateFormat('yyyy-MM-dd').parse(currentMatch.group(2)!);

    final latestVersionNumber = latestMatch.group(1)!;
    final latestIsStable = latestMatch.group(2) == null; // 안정 버전 여부
    final latestChannel = latestMatch.group(2); // d 또는 f 또는 null
    final latestChannelNumber =
        latestMatch.group(3) != null ? int.parse(latestMatch.group(3)!) : null;
    final latestDate = DateFormat('yyyy-MM-dd').parse(latestMatch.group(2)!);

    // 1. 안정 버전 vs 개발버전 (d/f) 비교 - 안정 버전이 항상 우선
    if (currentIsStable && !latestIsStable) {
      // 현재 버전이 안정 버전이고 최신 버전이 개발 버전이면,
      // 안정 버전 번호를 비교해서 결정
      // 동일한 버전 번호라면 업데이트 불필요 (안정 버전 우선)
      if (currentVersionNumber == latestVersionNumber) {
        return false;
      }
    } else if (!currentIsStable && latestIsStable) {
      // 현재 버전이 개발 버전이고 최신 버전이 안정 버전이면,
      // 버전 번호 비교 결과와 상관없이 업데이트 필요
      if (currentVersionNumber == latestVersionNumber) {
        return true; // 같은 번호여도 개발 -> 안정 업데이트는 필요
      }
    }

    // 2. 버전 번호 비교 (주요버전.마이너버전.패치버전)
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

    // 3. 버전 번호가 같은 경우, 채널 타입 비교
    // 둘 다 안정 버전이거나 둘 다 개발 버전인 경우
    if (currentIsStable == latestIsStable) {
      // 둘 다 안정 버전이면 날짜로 결정
      if (currentIsStable) {
        return latestDate.isAfter(currentDate);
      }

      // 둘 다 개발 버전이면, 채널 타입 및 번호 비교
      if (currentChannel != latestChannel) {
        // d 버전이 f 버전보다 낮음
        return currentChannel == 'd' && latestChannel == 'f';
      }

      // 같은 채널 타입일 경우 번호 비교
      if (currentChannelNumber != latestChannelNumber) {
        return currentChannelNumber! < latestChannelNumber!;
      }

      // 채널 타입과 번호가 모두 같으면 날짜 비교
      return latestDate.isAfter(currentDate);
    }

    // 버전이 완전히 동일한 경우
    return false;
  }
}
