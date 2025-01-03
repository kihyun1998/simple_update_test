import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_config.dart';

class ConfigRepository {
  static final ConfigRepository _instance = ConfigRepository._internal();
  factory ConfigRepository() => _instance;

  ConfigRepository._internal();

  Future<String> get _localPath async {
    final docDir = await getApplicationDocumentsDirectory();
    final configDir = Directory("${docDir.path}\\.testfolder");

    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    return configDir.path;
  }

  Future<File> get _configFile async {
    final path = await _localPath;
    return File("$path\\config.json");
  }

  Future<AppConfig> loadConfig() async {
    try {
      final file = await _configFile;
      if (!await file.exists()) {
        return const AppConfig(
          title: 'Default Title',
          ip: 'localhost:8080',
          name: 'server',
          fromVersion: null,
        );
      }

      final jsonString = await file.readAsString();
      final jsonMap = json.decode(jsonString);
      return AppConfig.fromJson(jsonMap);
    } catch (e) {
      return const AppConfig(
        title: 'Default Title',
        ip: 'localhost:8080',
        name: 'server',
        fromVersion: null,
      );
    }
  }

  Future<void> saveConfig(AppConfig config) async {
    final file = await _configFile;
    final jsonString = json.encode({
      'title': config.title,
      'profileList': [
        {
          'name': config.name,
          'ip': config.ip,
        }
      ]
    });
    await file.writeAsString(jsonString);
  }
}
