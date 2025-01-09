import 'dart:convert';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:simple_update_test/core/config/models/app_config.dart';
import 'package:simple_update_test/core/logging/logger.dart';
import 'package:simple_update_test/core/version/version_info.dart';
import 'package:simple_update_test/core/version/version_manager.dart';
import 'package:win32/win32.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  final Logger _logger = Logger();
  Version? _latestVersion;
  late final Version _currentVersion;
  factory UpdateService() => _instance;
  UpdateService._internal() {
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final jsonString = await rootBundle.loadString('assets/version.json');
      final json = jsonDecode(jsonString);
      final versionInfo = VersionInfo.fromJson(json);
      _currentVersion = Version.fromVersionInfo(versionInfo);
      _logger.info('Loaded version: ${_currentVersion.formattedVersion}');
    } catch (e, stackTrace) {
      _logger.error(e, stackTrace);
      // 폴백 버전 설정
      _currentVersion = const Version(
        s: "Flutter_APP_V1.0.0(2024-01-01)",
        c: Colors.blue,
      );
    }
  }

  Version get currentVersion => _currentVersion;
  Version? get latestVersion => _latestVersion;

  Future<bool> checkForUpdates(AppConfig config) async {
    final serverUrl = '${config.ip}/update/updatefilename';

    try {
      final response = await http.get(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('filename')) {
          final latestVersion = jsonResponse['filename'];
          _latestVersion = Version.parse(latestVersion);
          return Version.isUpdateAvailable(
            _currentVersion.formattedVersion,
            _latestVersion!.formattedVersion,
          );
        }
      }
      return false;
    } catch (e, stackTrace) {
      _logger.error(e, stackTrace);
      return false;
    }
  }

  Future<void> startUpdate() async {
    final updaterPath = path.join(Directory.current.path, 'dupdater.exe');

    if (!await File(updaterPath).exists()) {
      throw Exception('Cannot find updater at: $updaterPath');
    }

    _logger.info('Launching updater...');
    final args = "-fromVersion ${_currentVersion.formattedVersion}";

    final result = _launchUpdaterWithElevation(
      updaterPath: updaterPath,
      args: args,
    );

    if (result != 0) {
      throw Exception('Failed to launch updater. Error code: $result');
    }

    // updater 실행 후 앱 종료를 위한 지연
    await Future.delayed(const Duration(seconds: 1));
    exit(0); // 앱 프로세스 종료
  }

  int _launchUpdaterWithElevation({
    required String updaterPath,
    required String args,
  }) {
    final lpFile = updaterPath.toNativeUtf16();
    final lpParameters = args.toNativeUtf16();
    final lpDirectory = Directory.current.path.toNativeUtf16();

    try {
      final result = ShellExecute(
        NULL,
        TEXT('runas'),
        lpFile,
        lpParameters,
        lpDirectory,
        SHOW_WINDOW_CMD.SW_NORMAL,
      );

      return result > 32 ? 0 : result;
    } finally {
      free(lpFile);
      free(lpParameters);
      free(lpDirectory);
    }
  }
}
