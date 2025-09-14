// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';

// /// Application logger with configuration and file output support
// class AppLogger {
//   final String name;
//   late final Logger _logger;
//   static LogOutput? _fileOutput;

//   AppLogger(this.name) {
//     _logger = Logger(
//       printer: PrettyPrinter(
//         methodCount: 0,
//         errorMethodCount: 5,
//         lineLength: 50,
//         colors: true,
//         printEmojis: true,
//         dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
//       ),
//       output: _getOutput(),
//       level: _getLogLevel(),
//     );
//   }

//   /// Initialize file logging (call once in main.dart)
//   static Future<void> initialize() async {
//     if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
//       try {
//         final directory = await getApplicationDocumentsDirectory();
//         final logFile = File('${directory.path}/app_logs.txt');
//         _fileOutput = FileOutput(file: logFile);
//       } catch (e) {
//         debugPrint('Failed to initialize file logging: $e');
//       }
//     }
//   }

//   LogOutput _getOutput() {
//     if (kDebugMode) {
//       return _fileOutput != null
//           ? MultiOutput([ConsoleOutput(), _fileOutput!])
//           : ConsoleOutput();
//     } else {
//       return _fileOutput ?? ConsoleOutput();
//     }
//   }

//   Level _getLogLevel() {
//     if (kDebugMode) {
//       return Level.debug;
//     } else if (kReleaseMode) {
//       return Level.warning;
//     } else {
//       return Level.info;
//     }
//   }

//   // Logging methods
//   void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.t(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.d(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   void info(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.i(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   void warning(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.w(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   void error(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.e(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   void fatal(dynamic message, {dynamic error, StackTrace? stackTrace}) {
//     _logger.f(_formatMessage(message), error: error, stackTrace: stackTrace);
//   }

//   // Convenience aliases
//   void t(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       trace(message, error: error, stackTrace: stackTrace);

//   void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       debug(message, error: error, stackTrace: stackTrace);

//   void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       info(message, error: error, stackTrace: stackTrace);

//   void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       warning(message, error: error, stackTrace: stackTrace);

//   void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       error(message, error: error, stackTrace: stackTrace);

//   void f(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       fatal(message, error: error, stackTrace: stackTrace);

//   String _formatMessage(dynamic message) {
//     return '[$name] $message';
//   }
// }

// /// Singleton logger for global use
// class GlobalLogger {
//   static final AppLogger _instance = AppLogger('APP');

//   static AppLogger get instance => _instance;

//   static void trace(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       _instance.trace(message, error: error, stackTrace: stackTrace);

//   static void debug(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       _instance.debug(message, error: error, stackTrace: stackTrace);

//   static void info(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       _instance.info(message, error: error, stackTrace: stackTrace);

//   static void warning(
//     dynamic message, {
//     dynamic error,
//     StackTrace? stackTrace,
//   }) => _instance.warning(message, error: error, stackTrace: stackTrace);

//   static void error(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       _instance.error(message, error: error, stackTrace: stackTrace);

//   static void fatal(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
//       _instance.fatal(message, error: error, stackTrace: stackTrace);
// }
