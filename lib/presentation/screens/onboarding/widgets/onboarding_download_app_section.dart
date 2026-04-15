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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingDownloadAppSection extends StatelessWidget {
  const OnboardingDownloadAppSection({super.key});

  static const List<_StoreLink> _mobileStoreLinks = [
    _StoreLink(
      titleKey: 'onboardingDownloadAndroidStoreButton',
      url:
          'https://play.google.com/store/apps/details?id=es.victorcarreras.quiz_app',
    ),
    _StoreLink(
      titleKey: 'onboardingDownloadHuaweiStoreButton',
      url: 'https://appgallery.huawei.com/app/C117142053',
    ),
    _StoreLink(
      titleKey: 'onboardingDownloadIosStoreButton',
      url: 'https://apps.apple.com/app/quiz-appl/id6758663432',
    ),
  ];

  static const List<_StoreLink> _desktopStoreLinks = [
    _StoreLink(
      titleKey: 'onboardingDownloadMacStoreButton',
      url: 'https://apps.apple.com/app/quiz-appl/id6758663432',
    ),
    _StoreLink(
      titleKey: 'onboardingDownloadWindowsStoreButton',
      url:
          'https://apps.microsoft.com/store/detail/9P77H0WRJSM2?cid=DevShareMCLPCS',
    ),
    _StoreLink(
      titleKey: 'onboardingDownloadLinuxStoreButton',
      url: 'https://snapcraft.io/quiz-app',
    ),
  ];

  void _showQrDialog(BuildContext context, _StoreLink storeLink) {
    final localizations = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;

        return Dialog(
          backgroundColor: colors.card,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colors.border, width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.qrCode,
                          size: 20,
                          color: colors.subtitle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.onboardingDownloadQrTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.title,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              storeLink.title(context),
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.onboardingDownloadQrDescription,
                    style: TextStyle(fontSize: 14, color: colors.subtitle),
                  ),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: QrImageView(
                          data: storeLink.url,
                          size: 240,
                          backgroundColor: AppTheme.surfaceColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  QuizdyButton(
                    type: QuizdyButtonType.primary,
                    title: localizations.okButton,
                    expanded: true,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDesktopStore(
    BuildContext context,
    _StoreLink storeLink,
  ) async {
    final url = Uri.parse(storeLink.url);
    final opened = await launchUrl(url);

    if (!opened && context.mounted) {
      context.presentSnackBar(
        AppLocalizations.of(context)!.couldNotOpenUrl(url.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.onboardingDownloadMobileSectionDescription,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        ..._mobileStoreLinks.map(
          (storeLink) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuizdyButton(
              type: QuizdyButtonType.secondary,
              title: storeLink.title(context),
              icon: LucideIcons.qrCode,
              expanded: true,
              onPressed: () => _showQrDialog(context, storeLink),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.onboardingDownloadDesktopSectionDescription,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        ..._desktopStoreLinks.map(
          (storeLink) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuizdyButton(
              type: QuizdyButtonType.secondary,
              title: storeLink.title(context),
              icon: LucideIcons.externalLink,
              expanded: true,
              onPressed: () => _openDesktopStore(context, storeLink),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreLink {
  final String titleKey;
  final String url;

  const _StoreLink({required this.titleKey, required this.url});

  String title(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return switch (titleKey) {
      'onboardingDownloadAndroidStoreButton' =>
        localizations.onboardingDownloadAndroidStoreButton,
      'onboardingDownloadHuaweiStoreButton' =>
        localizations.onboardingDownloadHuaweiStoreButton,
      'onboardingDownloadIosStoreButton' =>
        localizations.onboardingDownloadIosStoreButton,
      'onboardingDownloadMacStoreButton' =>
        localizations.onboardingDownloadMacStoreButton,
      'onboardingDownloadWindowsStoreButton' =>
        localizations.onboardingDownloadWindowsStoreButton,
      'onboardingDownloadLinuxStoreButton' =>
        localizations.onboardingDownloadLinuxStoreButton,
      _ => titleKey,
    };
  }
}
