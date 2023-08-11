import 'package:logger/logger.dart';

class AppLogger {
  // Singleton
  static final AppLogger _singleton = AppLogger._internal();

  factory AppLogger() => _singleton;

  AppLogger._internal();

  final Logger _logger = Logger(
    printer: SimplePrinter(),
  );

  void error(dynamic event, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('$event', error: error, stackTrace: stackTrace);
  }

  void warning(dynamic event) {
    _logger.w('$event');
  }

  void debug(dynamic event) {
    _logger.d('$event');
  }

  void trace(dynamic event) {
    _logger.i('$event');
  }
}
