import 'package:logger/logger.dart';

class LoggerUtil extends Logger {
  LogPrinter printer;

  LoggerUtil({
    required this.printer,
  });

  void error(dynamic error, StackTrace? stackTrace, {String? message}) {
    e('[ERROR] $message', error: error, stackTrace: stackTrace);
  }

  void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      w('[WARN] $message', error: error, stackTrace: stackTrace);

  void info(dynamic message) => i('[INFO] $message');

  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      d('[DEBUG] $message', error: error, stackTrace: stackTrace);

  void verbose(dynamic message) => t('[VERBOSE]\n$message');

  static Level logLevel({bool replicateNonTestEnv = false}) => Level.trace;
}
