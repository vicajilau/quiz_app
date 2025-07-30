import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExtension on Color {
  static Color get random {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
