import 'package:flutter/material.dart';

class FileLoadedTheme extends ThemeExtension<FileLoadedTheme> {
  final Color deleteDialogBackgroundColor;
  final Color deleteDialogTextColor;
  final Color deleteDialogSubTextColor;
  final Color appBarIconBackgroundColor;
  final Color selectionInactiveBackgroundColor;
  final Color dragOverlayColor;
  final Color dragOverlayBorderColor;
  final Color dragOverlayShadowColor;

  const FileLoadedTheme({
    required this.deleteDialogBackgroundColor,
    required this.deleteDialogTextColor,
    required this.deleteDialogSubTextColor,
    required this.appBarIconBackgroundColor,
    required this.selectionInactiveBackgroundColor,
    required this.dragOverlayColor,
    required this.dragOverlayBorderColor,
    required this.dragOverlayShadowColor,
  });

  @override
  FileLoadedTheme copyWith({
    Color? deleteDialogBackgroundColor,
    Color? deleteDialogTextColor,
    Color? deleteDialogSubTextColor,
    Color? appBarIconBackgroundColor,
    Color? selectionInactiveBackgroundColor,
    Color? dragOverlayColor,
    Color? dragOverlayBorderColor,
    Color? dragOverlayShadowColor,
  }) {
    return FileLoadedTheme(
      deleteDialogBackgroundColor:
          deleteDialogBackgroundColor ?? this.deleteDialogBackgroundColor,
      deleteDialogTextColor:
          deleteDialogTextColor ?? this.deleteDialogTextColor,
      deleteDialogSubTextColor:
          deleteDialogSubTextColor ?? this.deleteDialogSubTextColor,
      appBarIconBackgroundColor:
          appBarIconBackgroundColor ?? this.appBarIconBackgroundColor,
      selectionInactiveBackgroundColor:
          selectionInactiveBackgroundColor ??
          this.selectionInactiveBackgroundColor,
      dragOverlayColor: dragOverlayColor ?? this.dragOverlayColor,
      dragOverlayBorderColor:
          dragOverlayBorderColor ?? this.dragOverlayBorderColor,
      dragOverlayShadowColor:
          dragOverlayShadowColor ?? this.dragOverlayShadowColor,
    );
  }

  @override
  FileLoadedTheme lerp(ThemeExtension<FileLoadedTheme>? other, double t) {
    if (other is! FileLoadedTheme) {
      return this;
    }
    return FileLoadedTheme(
      deleteDialogBackgroundColor: Color.lerp(
        deleteDialogBackgroundColor,
        other.deleteDialogBackgroundColor,
        t,
      )!,
      deleteDialogTextColor: Color.lerp(
        deleteDialogTextColor,
        other.deleteDialogTextColor,
        t,
      )!,
      deleteDialogSubTextColor: Color.lerp(
        deleteDialogSubTextColor,
        other.deleteDialogSubTextColor,
        t,
      )!,
      appBarIconBackgroundColor: Color.lerp(
        appBarIconBackgroundColor,
        other.appBarIconBackgroundColor,
        t,
      )!,
      selectionInactiveBackgroundColor: Color.lerp(
        selectionInactiveBackgroundColor,
        other.selectionInactiveBackgroundColor,
        t,
      )!,
      dragOverlayColor: Color.lerp(
        dragOverlayColor,
        other.dragOverlayColor,
        t,
      )!,
      dragOverlayBorderColor: Color.lerp(
        dragOverlayBorderColor,
        other.dragOverlayBorderColor,
        t,
      )!,
      dragOverlayShadowColor: Color.lerp(
        dragOverlayShadowColor,
        other.dragOverlayShadowColor,
        t,
      )!,
    );
  }
}

extension FileLoadedThemeContext on BuildContext {
  FileLoadedTheme get fileLoadedTheme =>
      Theme.of(this).extension<FileLoadedTheme>()!;
}
