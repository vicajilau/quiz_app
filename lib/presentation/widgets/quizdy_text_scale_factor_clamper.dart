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

import 'package:flutter/material.dart';

/// {@template text_scale_factor_clamper}
/// Constrains text scale factor of app to certain range.
///
/// Wraps all widgets created under the [MaterialApp].
/// ```
/// MaterialApp(
///   builder: (_, child) => TextScaleFactorClamper(child: child!),
///   ...
/// ),
/// ```
/// {@endtemplate}
class QuizdyTextScaleFactorClamper extends StatelessWidget {
  /// {@macro text_scale_factor_clamper}
  const QuizdyTextScaleFactorClamper({
    super.key,
    required this.child,
    this.minTextScaleFactor,
    this.maxTextScaleFactor,
  }) : assert(
         minTextScaleFactor == null ||
             maxTextScaleFactor == null ||
             minTextScaleFactor <= maxTextScaleFactor,
         'minTextScaleFactor must be less than maxTextScaleFactor',
       ),
       assert(
         maxTextScaleFactor == null ||
             minTextScaleFactor == null ||
             maxTextScaleFactor >= minTextScaleFactor,
         'maxTextScaleFactor must be greater than minTextScaleFactor',
       );

  /// Child widget.
  final Widget child;

  /// Min text scale factor.
  final double? minTextScaleFactor;

  /// Max text scale factor.
  final double? maxTextScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final constrainedTextScaleFactor = mediaQueryData.textScaler.clamp(
      minScaleFactor: minTextScaleFactor ?? 1,
      maxScaleFactor: maxTextScaleFactor ?? 1.3,
    );

    return MediaQuery(
      data: mediaQueryData.copyWith(textScaler: constrainedTextScaleFactor),
      child: child,
    );
  }
}
