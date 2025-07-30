import 'package:flutter/services.dart';

/// Handles file interactions through platform channels.
class FileHandler {
  /// The platform method channel for handling file operations.
  static const _channel = MethodChannel('maso.file');

  /// Initializes the file handler by setting up a method call listener.
  ///
  /// - [onFileOpened]: Callback function triggered when a file is opened.
  static void initialize(Function(String filePath) onFileOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final filePath = call.arguments as String;
        onFileOpened(filePath);
      }
    });
  }
}
