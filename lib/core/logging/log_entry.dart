import 'package:intl/intl.dart';

import 'log_level.dart';

class LogEntry {
  final LogLevel level;
  final String message;
  final String callerInfo;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    required this.callerInfo,
  }) : timestamp = DateTime.now();

  String get formattedMessage {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    return '${dateFormat.format(timestamp)} [${level.name}] $callerInfo :: $message';
  }
}
