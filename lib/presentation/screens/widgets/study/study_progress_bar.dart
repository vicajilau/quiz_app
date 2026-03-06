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

class StudyProgressBar extends StatelessWidget {
  final double progressPercentage;

  const StudyProgressBar({
    super.key,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filledFlex = (progressPercentage * 100).round().clamp(0, 10000);
    final remainingFlex = (10000 - filledFlex).clamp(0, 10000);

    return Row(
      children: [
        if (filledFlex > 0)
          Flexible(
            flex: filledFlex,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        const SizedBox(width: 4),
        Text(
          '${progressPercentage.toStringAsFixed(0)}%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        if (remainingFlex > 0)
          Flexible(
            flex: remainingFlex,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}
