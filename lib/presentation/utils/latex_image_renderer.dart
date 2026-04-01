// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders LaTeX equations off-screen using [Math.tex] + [RepaintBoundary]
/// and captures each result as PNG bytes suitable for embedding in a PDF.
class LaTeXImageRenderer {
  LaTeXImageRenderer._();

  /// Renders each unique equation from [equations] off-screen and returns a
  /// map from the original equation string to its PNG [Uint8List].
  ///
  /// Equations that fail to render are omitted from the result.
  static Future<Map<String, Uint8List>> renderEquations(
    BuildContext context,
    List<String> equations,
  ) async {
    final results = <String, Uint8List>{};
    for (final eq in equations.toSet()) {
      if (eq.trim().isEmpty) continue;
      final bytes = await _renderSingle(context, eq);
      if (bytes != null) results[eq] = bytes;
    }
    return results;
  }

  static Future<Uint8List?> _renderSingle(
    BuildContext context,
    String equation,
  ) async {
    if (equation.trim().isEmpty) return null;

    final key = GlobalKey();
    OverlayEntry? entry;

    try {
      entry = OverlayEntry(
        builder: (_) => Positioned(
          left: -10000,
          top: -10000,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: MediaQuery.of(context),
              child: RepaintBoundary(
                key: key,
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Math.tex(
                      equation.trim(),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      mathStyle: MathStyle.display,
                      onErrorFallback: (_) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(entry);

      await WidgetsBinding.instance.endOfFrame;

      final renderObject =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (renderObject == null) return null;

      final image = await renderObject.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      entry?.remove();
    }
  }
}
