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
import 'package:quizdy/core/theme/app_theme.dart';

class QuizdySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeTrackColor;

  const QuizdySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: activeTrackColor ?? Theme.of(context).primaryColor,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: isDark ? AppTheme.zinc600 : AppTheme.zinc300,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}
