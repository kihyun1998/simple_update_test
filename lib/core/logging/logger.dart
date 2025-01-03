import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'log_entry.dart';
import 'log_level.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  static const int _maxConcurrentWrites = 5;

  final Map<String, IOSink> _logSinks = {};
  final Queue<LogEntry> _logQueue = Queue<LogEntry>();
  int _activeWrites = 0;
  Completer<void>? _processingCompleter;

  Logger._internal();

  factory Logger() => _instance;

  static String _getCallerInfo() {
    final frames = StackTrace.current.toString().split('\n');
    const framesToSkip = 3;
    if (frames.length > framesToSkip) {
      final frame = frames[framesToSkip];
      final regex = RegExp(r'#\d+\s+(.+) \((.+?):(\d+)(?::\d+)?\)');
      final match = regex.firstMatch(frame);
      if (match != null) {
        final method = match.group(1);
        final file = match.group(2)?.split('/').last;
        final line = match.group(3);
        return '[$file:$line] in $method';
      }
    }
    return '[Unknown location]';
  }

  void log({
    required LogLevel level,
    required String message,
    required String filePath,
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      callerInfo: _getCallerInfo(),
    );

    _logQueue.add(entry);
    _processQueue();
  }

  Future<void> _processLogEntry(LogEntry entry, String filePath) async {
    _activeWrites++;
    try {
      final sink = await _getLogSink(filePath);
      sink.writeln(entry.formattedMessage);
      await sink.flush();
    } catch (e) {
      print('Error writing log: $e');
    } finally {
      _activeWrites--;
      _processQueue();
    }
  }

  Future<IOSink> _getLogSink(String filePath) async {
    if (!_logSinks.containsKey(filePath)) {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      _logSinks[filePath] = file.openWrite(mode: FileMode.append);
    }
    return _logSinks[filePath]!;
  }

  void _processQueue() {
    if (_processingCompleter != null) return;
    _processingCompleter = Completer<void>();

    Future<void> processNext() async {
      if (_logQueue.isEmpty) {
        _processingCompleter?.complete();
        _processingCompleter = null;
        return;
      }

      if (_activeWrites < _maxConcurrentWrites) {
        final entry = _logQueue.removeFirst();
        await _processLogEntry(entry, 'path_to_log_file.log'); // 실제 경로로 변경 필요
        processNext();
      }
    }

    processNext();
  }

  // 편의성 메서드들
  void debug(String message) =>
      log(level: LogLevel.debug, message: message, filePath: 'debug.log');
  void info(String message) =>
      log(level: LogLevel.info, message: message, filePath: 'info.log');
  void warn(String message) =>
      log(level: LogLevel.warn, message: message, filePath: 'warn.log');
  void error(Object error, StackTrace stackTrace) => log(
        level: LogLevel.error,
        message:
            "ERROR: ${error.toString()}\nSTACKTRACE: ${stackTrace.toString()}",
        filePath: 'error.log',
      );

  Future<void> dispose() async {
    while (_logQueue.isNotEmpty || _activeWrites > 0) {
      await _processingCompleter?.future;
    }
    for (var sink in _logSinks.values) {
      await sink.flush();
      await sink.close();
    }
    _logSinks.clear();
  }
}
