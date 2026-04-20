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
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/routes/app_router.dart';

class SettingsOnboardingRow extends StatelessWidget {
  final ConfirmingDialogColorsExtension colors;

  const SettingsOnboardingRow({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await ServiceLocator.getIt<ConfigurationService>()
            .setOnboardingCompleted(false);
        if (context.mounted) {
          context.pop();
          context.push('${AppRoutes.onboarding}?from=settings');
        }
      },
      child: _SettingsRow(
        icon: LucideIcons.graduationCap,
        title: AppLocalizations.of(context)!.showOnboarding,
        description: AppLocalizations.of(context)!.showOnboardingDescription,
        colors: colors,
      ),
    );
  }
}

class SettingsVersionRow extends StatelessWidget {
  final ConfirmingDialogColorsExtension colors;
  final String version;
  final VoidCallback onTap;

  const SettingsVersionRow({
    super.key,
    required this.colors,
    required this.version,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: _SettingsRow(
        icon: LucideIcons.info,
        title: AppLocalizations.of(context)!.versionLabel,
        description: version,
        colors: colors,
      ),
    );
  }
}

class SettingsPrivacyPolicyRow extends StatelessWidget {
  final ConfirmingDialogColorsExtension colors;

  const SettingsPrivacyPolicyRow({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.pop();
        context.push('${AppRoutes.privacyPolicy}?from=settings');
      },
      child: _SettingsRow(
        icon: LucideIcons.shield,
        title: AppLocalizations.of(context)!.privacyPolicyLabel,
        description: AppLocalizations.of(context)!.privacyPolicyDescription,
        colors: colors,
      ),
    );
  }
}

class SettingsSupportRow extends StatelessWidget {
  final ConfirmingDialogColorsExtension colors;
  final VoidCallback onTap;

  const SettingsSupportRow({
    super.key,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: _SettingsRow(
        icon: LucideIcons.lifeBuoy,
        title: AppLocalizations.of(context)!.supportLabel,
        description: AppLocalizations.of(context)!.supportDescription,
        colors: colors,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ConfirmingDialogColorsExtension colors;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colors.subtitle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.title,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: colors.subtitle),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: colors.subtitle),
        ],
      ),
    );
  }
}
