import 'package:flutter/foundation.dart';

/// Prints the given [object] to the console in debug mode.
///
/// This method ensures that the message is only logged when the application
/// is running in debug mode, preventing unnecessary logs in release builds.
///
/// - [object]: The message or object to print.
void printInDebug(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
