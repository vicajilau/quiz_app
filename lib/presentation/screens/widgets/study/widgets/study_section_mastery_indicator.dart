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

class StudySectionMasteryIndicator extends StatelessWidget {
  final double percentage;
  final String tooltipText;

  const StudySectionMasteryIndicator({
    super.key,
    required this.percentage,
    required this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on mastery percentage
    final Color progressColor = percentage >= 90
        ? Colors.green.shade600
        : (percentage >= 50 ? Colors.orange.shade500 : Colors.red.shade600);

    final Color trackColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    final Color textColor = isDark
        ? AppTheme.backgroundColor
        : AppTheme.zinc900;

    return Tooltip(
      message: tooltipText,
      triggerMode: TooltipTriggerMode.longPress, // Good for touch screens
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 3.5,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
