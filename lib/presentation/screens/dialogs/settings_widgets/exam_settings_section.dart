import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

/// A widget that handles the exam mode settings section.
///
/// Allows the user to enable/disable the exam timer and configure the time limit in minutes.
class ExamSettingsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.examTimeLimitTitle),
          subtitle: Text(
            AppLocalizations.of(context)!.examTimeLimitDescription,
          ),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: minutes.toString(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.timeLimitMinutes,
              border: const OutlineInputBorder(),
              suffixText: AppLocalizations.of(context)!.minutesAbbreviation,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final newMinutes = int.tryParse(value);
              if (newMinutes != null && newMinutes > 0) {
                onMinutesChanged(newMinutes);
              }
            },
          ),
        ],
      ],
    );
  }
}
