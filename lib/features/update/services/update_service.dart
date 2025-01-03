import 'dart:convert';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:simple_update_test/core/config/models/app_config.dart';
import 'package:simple_update_test/core/logging/logger.dart';
import 'package:simple_update_test/core/version/version_manager.dart';
import 'package:simple_update_test/core/version/version_type.dart';
import 'package:win32/win32.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  final Logger _logger = Logger();
  Version? _latestVersion;
  final Version _currentVersion;

  /// 여기서 버전 변경 가능
  UpdateService._internal()
      : _currentVersion = Version.fromType(VersionType.v10000240101);

  factory UpdateService() => _instance;

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
    final updaterPath = path.join(Directory.current.path, 'updater.exe');

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
