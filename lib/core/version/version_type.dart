import 'package:flutter/material.dart';

enum VersionType {
  v10000240101,
  v10000240102,
  v10001240103;

  String getVersion() {
    switch (this) {
      case VersionType.v10000240101:
        return "Test_V1.0.0(2024-01-01)";
      case VersionType.v10000240102:
        return "Test_V1.0.0(2024-01-02)";
      case VersionType.v10001240103:
        return "Test_V1.0.1(2024-01-03)";
    }
  }

  Color getColor() {
    switch (this) {
      case VersionType.v10000240101:
        return Colors.red;
      case VersionType.v10000240102:
        return Colors.green;
      case VersionType.v10001240103:
        return Colors.blue;
    }
  }

  static VersionType fromString(String version) {
    try {
      return VersionType.values.firstWhere(
        (element) => element.getVersion() == version,
      );
    } catch (error) {
      return VersionType.v10000240101; // 기본값
    }
  }
}
