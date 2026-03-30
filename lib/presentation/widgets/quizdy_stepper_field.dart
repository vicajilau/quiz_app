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
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/screens/dialogs/count_selection/count_control_button.dart';

/// A stepper input composed of a decrement button, a centered text field, and
/// an increment button. Colors and sizing follow the global design system and
/// are resolved from the current theme — no style parameters required.
class QuizdyStepperField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuizdyStepperField({
    super.key,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    final decrementIconColor = isDark ? AppTheme.zinc400 : AppTheme.zinc700;
    final textColor = isDark ? Colors.white : AppTheme.zinc900;

    return Row(
      children: [
        CountControlButton(
          icon: LucideIcons.minus,
          onTap: onDecrement,
          bgColor: containerColor,
          iconColor: decrementIconColor,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        CountControlButton(
          icon: LucideIcons.plus,
          onTap: onIncrement,
          bgColor: Theme.of(context).primaryColor,
          iconColor: Colors.white,
        ),
      ],
    );
  }
}
