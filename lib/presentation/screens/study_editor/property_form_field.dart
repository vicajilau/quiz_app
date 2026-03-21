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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

/// Scrollable column of form children with uniform vertical spacing.
class PropertySimpleForm extends StatelessWidget {
  final List<Widget> children;

  const PropertySimpleForm({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Single labeled text field (single-line or multiline), with optional marker.
class PropertyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool optional;
  final bool multiline;

  const PropertyField({
    super.key,
    required this.label,
    required this.controller,
    this.optional = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            QuizdyFieldLabel(label: label),
            if (optional) ...[
              const SizedBox(width: 4),
              Text(
                '(${l.componentFieldOptional})',
                style: const TextStyle(fontSize: 11, color: AppTheme.zinc500),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        QuizdyTextField(
          controller: controller,
          hint: label,
          minLines: multiline ? 4 : 1,
          maxLines: multiline ? null : 1,
          keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
        ),
      ],
    );
  }
}
