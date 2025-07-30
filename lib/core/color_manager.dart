import 'dart:math';

import 'package:flutter/material.dart';

class ColorManager {
  final Map<String, Color> _colorMap = {};
  final Set<Color> _usedColors = {};

  /// If the process name is already in the map, return the corresponding color.
  /// Otherwise, generate a new color and add it to the map.
  Color getColorForProcess(String processName) {
    if (_colorMap.containsKey(processName)) {
      return _colorMap[processName]!;
    }

    Color newColor = _generateUniquePastelColor();
    _colorMap[processName] = newColor;
    _usedColors.add(newColor);
    return newColor;
  }

  /// Generate a pastel color that has not been used 100 times.
  /// If it fails 100 times a random color is generated.
  Color _generateUniquePastelColor() {
    const int maxAttempts = 100;
    for (int i = 0; i < maxAttempts; i++) {
      final pastelColor = _generatePastelColor();
      if (!_usedColors.contains(pastelColor)) {
        return pastelColor;
      }
    }
    return _generatePastelColor();
  }

  /// Generate a random pastel color.
  Color _generatePastelColor() {
    final Random random = Random();
    int r = (random.nextInt(128) + 127); // 127–255
    int g = (random.nextInt(128) + 127);
    int b = (random.nextInt(128) + 127);
    return Color.fromARGB(255, r, g, b);
  }
}
