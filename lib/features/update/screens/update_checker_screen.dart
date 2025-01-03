import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/config/models/app_config.dart';
import '../../../core/config/repositories/config_repository.dart';
import '../services/update_service.dart';

class UpdateCheckerScreen extends StatefulWidget {
  const UpdateCheckerScreen({super.key});

  @override
  _UpdateCheckerScreenState createState() => _UpdateCheckerScreenState();
}

class _UpdateCheckerScreenState extends State<UpdateCheckerScreen> {
  final UpdateService _updateService = UpdateService();
  String _updateStatus = 'Click to check for updates';
  late AppConfig _appConfig;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final configRepo = ConfigRepository();
    _appConfig = await configRepo.loadConfig();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _updateService.currentVersion.color,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text("${_appConfig.title} - ${_appConfig.name}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_updateStatus),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _appConfig.fromVersion != null
                    ? "version: ${_appConfig.fromVersion} to ${_updateService.currentVersion.formattedVersion}"
                    : "version: ${_updateService.currentVersion.formattedVersion}",
              ),
            ),
            ElevatedButton(
              onPressed: _checkForUpdates,
              child: const Text('Check for Updates'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = 'Checking for updates...';
    });

    try {
      final updateAvailable = await _updateService.checkForUpdates(_appConfig);

      setState(() {
        if (updateAvailable) {
          _updateStatus =
              'Update available: ${_updateService.latestVersion?.formattedVersion}';
          _startUpdate();
        } else {
          _updateStatus = 'You have the latest version';
        }
      });
    } catch (e) {
      setState(() {
        _updateStatus = 'Error checking for updates: $e';
      });
    }
  }

  Future<void> _startUpdate() async {
    try {
      await _updateService.startUpdate();
      await Future.delayed(const Duration(seconds: 1));
      exit(0);
    } catch (e) {
      setState(() {
        _updateStatus = 'Error starting update: $e';
      });
    }
  }
}
