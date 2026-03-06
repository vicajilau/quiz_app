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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/domain/models/quiz/ui_element.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';

class WarningComponent extends StatelessWidget {
  final UiElement element;

  const WarningComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final body = element.props['body']?.toString() ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? Colors.orange[900]?.withValues(alpha: 0.2)
        : Colors.orange[50];
    final borderColor = isDark ? Colors.orange[700]! : Colors.orange[300]!;
    final iconColor = isDark ? Colors.orange[400] : Colors.orange[800];

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(child: MarkdownWidget(data: body)),
        ],
      ),
    );
  }
}
