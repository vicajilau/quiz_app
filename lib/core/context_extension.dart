import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SnackbarExtension on BuildContext {
  /// Displays a snack bar with the given text message.
  ///
  /// This method uses the `ScaffoldMessenger` to show a `SnackBar`
  /// containing the provided `text`. The `BuildContext` must be valid
  /// within the widget tree.
  ///
  /// - Parameters:
  ///   - text: The message to display in the `SnackBar`.
  ///
  /// Example usage:
  /// ```dart
  /// context.presentSnackBar("File uploaded successfully!");
  /// ```
  void presentSnackBar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }
}

extension NavigationExtension on BuildContext {
  /// Returns the current route location from GoRouter.
  String get currentRoute {
    return GoRouter.of(
      this,
    ).routerDelegate.currentConfiguration.matches.last.matchedLocation;
  }
}
