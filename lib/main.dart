import 'package:args/args.dart';
import 'package:flutter/material.dart';

import 'features/setup/setup_manager.dart';
import 'features/update/screens/update_checker_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final parser = ArgParser()
    ..addFlag('patch', abbr: 'p', defaultsTo: false, help: 'patch mode')
    ..addOption('fromVersion',
        abbr: 'f', defaultsTo: null, help: 'From Update Version');

  // 초기 설정
  await SetupManager().initialize(parser: parser, args: args);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Checker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UpdateCheckerScreen(),
    );
  }
}
