import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error, fatal }

extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return "DEBUG";
      case LogLevel.info:
        return "INFO";
      case LogLevel.warning:
        return "WARNING";
      case LogLevel.error:
        return "ERROR";
      case LogLevel.fatal:
        return "FATAL";
    }
  }
}

class CustomLogger {
  static final CustomLogger _instance = CustomLogger._internal();

  factory CustomLogger() => _instance;

  CustomLogger._internal();

  bool enableFileLogging = false; // Set to true for file logging

  /// Get formatted timestamp
  String _getTimestamp() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  /// Format log message
  String _formatLog(LogLevel level, String message, [dynamic data]) {
    final timestamp = _getTimestamp();
    String logString = "[$timestamp] [${level.name}] $message";

    if (data != null) {
      if (data is Map || data is List) {
        logString += "\n${_formatJson(data)}";
      } else {
        logString += " | Data: $data";
      }
    }

    return logString;
  }

  /// Pretty print JSON
  String _formatJson(dynamic jsonObject) {
    try {
      return JsonEncoder.withIndent('  ').convert(jsonObject);
    } catch (e) {
      return jsonObject.toString();
    }
  }

  /// Log to console
  void _logToConsole(LogLevel level, String message, [dynamic data]) {
    final formattedLog = _formatLog(level, message, data);
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        if (kDebugMode) print("\x1B[32m$formattedLog\x1B[0m"); // Green
        break;
      case LogLevel.warning:
        if (kDebugMode) print("\x1B[33m$formattedLog\x1B[0m"); // Yellow
        break;
      case LogLevel.error:
        if (kDebugMode) print("\x1B[31m$formattedLog\x1B[0m"); // Red
        break;
      case LogLevel.fatal:
        if (kDebugMode) print("\x1B[41m$formattedLog\x1B[0m"); // Red Background
        break;
    }
  }

  /// Log to file
  Future<void> _logToFile(String logMessage) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app_logs.txt');
      await file.writeAsString("$logMessage\n", mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) print("Failed to write log to file: $e");
    }
  }

  /// Public log methods
  void log(LogLevel level, String message, [dynamic data]) {
    _logToConsole(level, message, data);
    if (enableFileLogging) _logToFile(_formatLog(level, message, data));
  }

  void debug(String message, [dynamic data]) =>
      log(LogLevel.debug, message, data);

  void info(String message, [dynamic data]) =>
      log(LogLevel.info, message, data);

  void warning(String message, [dynamic data]) =>
      log(LogLevel.warning, message, data);

  void error(String message, [dynamic data]) =>
      log(LogLevel.error, message, data);

  void fatal(String message, [dynamic data]) =>
      log(LogLevel.fatal, message, data);
}
