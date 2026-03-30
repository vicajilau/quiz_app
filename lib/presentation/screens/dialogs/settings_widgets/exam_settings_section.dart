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
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

/// A widget that handles the exam mode settings section.
///
/// Allows the user to enable/disable the exam timer and configure the time limit in minutes.
class ExamSettingsSection extends StatefulWidget {
  final bool enabled;
  final int minutes;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onMinutesChanged;

  const ExamSettingsSection({
    super.key,
    required this.enabled,
    required this.minutes,
    required this.onEnabledChanged,
    required this.onMinutesChanged,
  });

  @override
  State<ExamSettingsSection> createState() => _ExamSettingsSectionState();
}

class _ExamSettingsSectionState extends State<ExamSettingsSection> {
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.minutes.toString(),
    );
  }

  @override
  void didUpdateWidget(ExamSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minutes != oldWidget.minutes &&
        _minutesController.text != widget.minutes.toString()) {
      _minutesController.text = widget.minutes.toString();
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.examTimeLimitTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.title,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.examTimeLimitDescription,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              QuizdySwitch(value: widget.enabled, onChanged: widget.onEnabledChanged),
            ],
          ),
        ),
        if (widget.enabled) ...[
          const SizedBox(height: 16),
          QuizdyFieldLabel(label: AppLocalizations.of(context)!.timeLimitMinutes),
          const SizedBox(height: 8),
          QuizdyTextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            suffixText: AppLocalizations.of(context)!.minutesAbbreviation,
            onChanged: (value) {
              final newMinutes = int.tryParse(value);
              if (newMinutes != null && newMinutes > 0) {
                widget.onMinutesChanged(newMinutes);
              }
            },
          ),
        ],
      ],
    );
  }
}
