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
///
/// Required fields (where [optional] is false) show an inline error message
/// when the user leaves the field empty after interacting with it.
class PropertyField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool optional;
  final bool multiline;

  /// When true, immediately shows the required-field error if the field is empty.
  /// Useful for triggering validation on a save attempt.
  final bool forceShowError;

  const PropertyField({
    super.key,
    required this.label,
    required this.controller,
    this.optional = false,
    this.multiline = false,
    this.forceShowError = false,
  });

  @override
  State<PropertyField> createState() => _PropertyFieldState();
}

class _PropertyFieldState extends State<PropertyField> {
  late final FocusNode _focusNode;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(PropertyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.forceShowError &&
        widget.forceShowError &&
        !widget.optional) {
      setState(() {
        _showError = widget.controller.text.trim().isEmpty;
      });
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !widget.optional) {
      setState(() {
        _showError = widget.controller.text.trim().isEmpty;
      });
    }
  }

  void _onTextChange() {
    if (_showError && widget.controller.text.trim().isNotEmpty) {
      setState(() => _showError = false);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            QuizdyFieldLabel(label: widget.label),
            if (widget.optional) ...[
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
          controller: widget.controller,
          focusNode: _focusNode,
          hint: widget.label,
          minLines: widget.multiline ? 4 : 1,
          maxLines: widget.multiline ? null : 1,
          keyboardType: widget.multiline
              ? TextInputType.multiline
              : TextInputType.text,
        ),
        if (_showError) ...[
          const SizedBox(height: 4),
          Text(
            l.componentFieldRequired,
            style: TextStyle(fontSize: 11, color: errorColor),
          ),
        ],
      ],
    );
  }
}
