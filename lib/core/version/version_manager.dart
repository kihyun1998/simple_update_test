import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'version_type.dart';

class Version {
  final String s;
  final Color c;

  const Version({
    required this.s,
    required this.c,
  });

  factory Version.parse(String versionString) {
    return Version(
      s: versionString,
      c: Colors.blue, // 기본 색상 지정
    );
  }

  factory Version.fromType(VersionType type) {
    return Version(
      s: type.getVersion(),
      c: type.getColor(),
    );
  }

  String get formattedVersion => s;
  Color get color => c;

  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    final currentMatch = RegExp(r'Test_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)')
        .firstMatch(currentVersion);
    final latestMatch = RegExp(r'Test_V(\d+\.\d+\.\d+)\((\d{4}-\d{2}-\d{2})\)')
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
