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
import 'package:go_router/go_router.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';
import 'package:quizdy/presentation/widgets/quizdy_loading.dart';
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/routes/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final bool fromSettings;
  final bool requireAcceptance;

  const PrivacyPolicyScreen({
    super.key,
    this.fromSettings = false,
    this.requireAcceptance = false,
  });

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://github.com/vicajilau/quizdy/blob/main/PRIVACY.md',
  );

  final ConfigurationService _configurationService =
      ServiceLocator.getIt<ConfigurationService>();

  String? _privacyPolicyMarkdown;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final markdown = await rootBundle.loadString('PRIVACY.md');

      if (mounted) {
        setState(() {
          _privacyPolicyMarkdown = markdown;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _privacyPolicyMarkdown = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptPrivacyPolicy() async {
    await _configurationService.setPrivacyPolicyAccepted(true);

    if (!mounted) {
      return;
    }

    if (widget.fromSettings) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }

  void _closeScreen() {
    if (!mounted) {
      return;
    }

    if (widget.fromSettings) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }

  Future<void> _openPrivacyPolicyUrl() async {
    final launched = await launchUrl(
      _privacyPolicyUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      context.presentSnackBar(
        AppLocalizations.of(
          context,
        )!.couldNotOpenUrl(_privacyPolicyUrl.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final canPopScreen = !widget.requireAcceptance;

    return PopScope(
      canPop: canPopScreen,
      child: Scaffold(
        appBar: QuizdyAppBar(
          showLeading: canPopScreen,
          onLeadingPressed: _closeScreen,
          title: Text(
            localizations.privacyPolicyLabel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.requireAcceptance) ...[
                  Text(
                    localizations.privacyPolicyRequiredDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.privacyPolicyCanonicalNotice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Text(
                    localizations.privacyPolicyCanonicalNotice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isLoading
                          ? const Center(child: QuizdyLoading())
                          : _privacyPolicyMarkdown == null
                          ? Center(
                              child: Text(
                                localizations.privacyPolicyLoadError,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SingleChildScrollView(
                              child: QuizdyMarkdown(
                                data: _privacyPolicyMarkdown!,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                QuizdyButton(
                  type: QuizdyButtonType.secondary,
                  title: localizations.privacyPolicyOpenInBrowser,
                  expanded: true,
                  onPressed: _openPrivacyPolicyUrl,
                ),
                const SizedBox(height: 12),
                if (widget.requireAcceptance)
                  QuizdyButton(
                    title: localizations.acceptButton,
                    expanded: true,
                    onPressed: _privacyPolicyMarkdown == null
                        ? null
                        : _acceptPrivacyPolicy,
                  )
                else
                  QuizdyButton(
                    title: localizations.close,
                    expanded: true,
                    onPressed: _closeScreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
