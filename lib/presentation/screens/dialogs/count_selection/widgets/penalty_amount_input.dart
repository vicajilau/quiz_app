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
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_stepper_field.dart';

class PenaltyAmountInput extends StatelessWidget {
  final Color subTextColor;
  final double penaltyAmount;
  final TextEditingController penaltyController;
  final FocusNode penaltyFocusNode;
  final ValueChanged<double> onPenaltyAmountChanged;
  final VoidCallback onIncrementPenalty;
  final VoidCallback onDecrementPenalty;

  const PenaltyAmountInput({
    super.key,
    required this.subTextColor,
    required this.penaltyAmount,
    required this.penaltyController,
    required this.penaltyFocusNode,
    required this.onPenaltyAmountChanged,
    required this.onIncrementPenalty,
    required this.onDecrementPenalty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.penaltyAmountLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            Text(
              AppLocalizations.of(
                context,
              )!.penaltyPointsLabel(penaltyAmount.toStringAsFixed(2)),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        QuizdyStepperField(
          controller: penaltyController,
          focusNode: penaltyFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onIncrement: onIncrementPenalty,
          onDecrement: onDecrementPenalty,
          onChanged: (value) {
            if (value.isEmpty) return;
            final normalizedValue = value.replaceAll(',', '.');
            final val = double.tryParse(normalizedValue);
            if (val != null && val >= 0) {
              onPenaltyAmountChanged(val);
            }
          },
        ),
      ],
    );
  }
}
