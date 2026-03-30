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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/widgets/quizdy_stepper_field.dart';

class MaxIncorrectLimitInput extends StatefulWidget {
  final Color subTextColor;
  final TextEditingController maxIncorrectAnswersController;
  final FocusNode maxIncorrectAnswersFocusNode;
  final ValueChanged<int> onMaxIncorrectAnswersLimitChanged;
  final VoidCallback onIncrementMaxIncorrect;
  final VoidCallback onDecrementMaxIncorrect;
  final ValueChanged<bool>? onMaxIncorrectErrorChanged;

  const MaxIncorrectLimitInput({
    super.key,
    required this.subTextColor,
    required this.maxIncorrectAnswersController,
    required this.maxIncorrectAnswersFocusNode,
    required this.onMaxIncorrectAnswersLimitChanged,
    required this.onIncrementMaxIncorrect,
    required this.onDecrementMaxIncorrect,
    this.onMaxIncorrectErrorChanged,
  });

  @override
  State<MaxIncorrectLimitInput> createState() => _MaxIncorrectLimitInputState();
}

class _MaxIncorrectLimitInputState extends State<MaxIncorrectLimitInput> {
  bool _hasError = false;

  void _updateError(bool hasError) {
    if (_hasError != hasError) {
      setState(() => _hasError = hasError);
      if (widget.onMaxIncorrectErrorChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onMaxIncorrectErrorChanged!(hasError);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.maxIncorrectAnswersLimitLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.subTextColor,
          ),
        ),
        const SizedBox(height: 12),
        QuizdyStepperField(
          controller: widget.maxIncorrectAnswersController,
          focusNode: widget.maxIncorrectAnswersFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onIncrement: widget.onIncrementMaxIncorrect,
          onDecrement: widget.onDecrementMaxIncorrect,
          onChanged: (value) {
            final val = int.tryParse(value);
            final hasError = value.isEmpty || val == null || val < 0;
            if (!hasError) widget.onMaxIncorrectAnswersLimitChanged(val);
            _updateError(hasError);
          },
        ),
        if (_hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              AppLocalizations.of(context)!.validationMin0GenericError,
              style: TextStyle(fontSize: 12, color: errorColor),
            ),
          ),
        ],
      ],
    );
  }
}
