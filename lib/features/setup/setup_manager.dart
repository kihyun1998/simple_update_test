import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/config/repositories/config_repository.dart';
import '../../core/logging/logger.dart';

class SetupManager {
  static final SetupManager _instance = SetupManager._internal();
  factory SetupManager() => _instance;

  SetupManager._internal();

  Future<void> initialize({
    required ArgParser parser,
    required List<String> args,
  }) async {
    final logger = Logger();
    try {
      final argResults = parser.parse(args);
      final isPatch = argResults['patch'];
      final fromVersion = argResults['fromVersion'];

      logger.info('Start setup - patch: $isPatch, fromVersion: $fromVersion');

      if (isPatch) {
        await _cleanupBackup();
      }

      if (fromVersion != null) {
        await _handleVersionUpgrade(fromVersion);
      }

      await _setupConfigFile();
    } catch (error, stackTrace) {
      logger.error(error, stackTrace);
    }
  }

  Future<void> _cleanupBackup() async {
    final tempDir = await getTemporaryDirectory();
    final backupPath = path.join(tempDir.path, 'ACRABACK');
    final backupDir = Directory(backupPath);

    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
      Logger().info('Backup folder deleted: $backupPath');
    }
  }

  Future<void> _handleVersionUpgrade(String fromVersion) async {
    // 기존 설정 불러오기
    final configRepo = ConfigRepository();
    final currentConfig = await configRepo.loadConfig();

    // fromVersion 정보 추가
    final updatedConfig = currentConfig.copyWith(
      fromVersion: fromVersion,
    );

    // 업데이트된 설정 저장
    await configRepo.saveConfig(updatedConfig);
  }

  Future<void> _setupConfigFile() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final testDir = Directory(path.join(
        docDir.path,
        Platform.pathSeparator,
        '..',
        Platform.pathSeparator,
        '.testfolder',
      ));

      // 디렉토리가 없으면 생성
      if (!await testDir.exists()) {
        await testDir.create(recursive: true);
      }

      final configFile = File(path.join(testDir.path, 'config.json'));

      // 새로운 설정 파일이 필요한 경우 생성
      if (!await configFile.exists()) {
        final defaultConfig = {
          "title": "Default Title",
          "profileList": [
            {
              "name": "server1",
              "ip": "http://localhost:8000",
            },
            {
              "name": "server2",
              "ip": "http://localhost:8000",
            }
          ]
        };

        await configFile.writeAsString(json.encode(defaultConfig));
        Logger().info('Created new config file at ${configFile.path}');
      }

      // 설정 로드 및 검증
      final configRepo = ConfigRepository();
      final config = await configRepo.loadConfig();
      Logger().info('Loaded config with title: ${config.title}');
    } catch (error, stackTrace) {
      Logger().error(error, stackTrace);
      throw Exception('Failed to setup config file: $error');
    }
  }
}
