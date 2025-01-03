enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal;

  String get name => toString().split('.').last.toUpperCase();
}
