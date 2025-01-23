import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_update_test/features/update/providers/update_service_notifier_provider.dart';
import 'package:simple_update_test/features/update/services/provider/counter_provider.dart';

import '../../../core/config/models/app_config.dart';
import '../../../core/config/repositories/config_repository.dart';
import '../services/update_service.dart';

class UpdateCheckerScreen extends ConsumerStatefulWidget {
  const UpdateCheckerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UpdateCheckerScreenState();
}

class _UpdateCheckerScreenState extends ConsumerState<UpdateCheckerScreen> {
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
    final count = ref.watch(counterProvider);
    final updateServiceAsyncValue = ref.watch(updateServiceNotifierProvider);

    return updateServiceAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      data: (data) {
        return Scaffold(
          backgroundColor: data.currentVersion?.color,
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
                        ? "version: ${_appConfig.fromVersion} to ${data.currentVersion?.formattedVersion}"
                        : "version: ${data.currentVersion?.formattedVersion}",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _checkForUpdates(data);
                  },
                  child: const Text('Check for Updates'),
                ),
                const SizedBox(height: 20),
                // 카운터 UI 추가
                Text(
                  '현재 카운트: $count',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.notifier).decrement(),
                      child: const Text('-'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.notifier).increment(),
                      child: const Text('+'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkForUpdates(UpdateService updateService) async {
    setState(() {
      _updateStatus = 'Checking for updates...';
    });

    try {
      final updateAvailable = await updateService.checkForUpdates(_appConfig);

      setState(() {
        if (updateAvailable) {
          _updateStatus =
              'Update available: ${updateService.latestVersion?.formattedVersion}';
          _startUpdate(updateService);
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

  Future<void> _startUpdate(UpdateService updateService) async {
    try {
      await updateService.startUpdate();
      await Future.delayed(const Duration(seconds: 1));
      exit(0);
    } catch (e) {
      setState(() {
        _updateStatus = 'Error starting update: $e';
      });
    }
  }
}
