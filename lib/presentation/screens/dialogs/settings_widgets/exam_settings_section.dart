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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final subtitleColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
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
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.examTimeLimitDescription,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF8B5CF6),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: isDark
                    ? const Color(0xFF52525B)
                    : const Color(0xFFD4D4D8),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
        ),
        if (enabled) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: minutes.toString(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.timeLimitMinutes,
              labelStyle: TextStyle(fontFamily: 'Inter', color: subtitleColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFE4E4E7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFE4E4E7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              suffixText: AppLocalizations.of(context)!.minutesAbbreviation,
            ),
            style: TextStyle(fontFamily: 'Inter', color: titleColor),
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
