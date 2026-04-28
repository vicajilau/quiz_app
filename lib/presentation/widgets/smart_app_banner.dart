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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SmartAppBanner extends StatefulWidget {
  final Widget child;

  const SmartAppBanner({super.key, required this.child});

  @override
  State<SmartAppBanner> createState() => _SmartAppBannerState();
}

class _SmartAppBannerState extends State<SmartAppBanner> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Only show on Web
    if (!kIsWeb) {
      _isVisible = false;
    }
  }

  void _openInApp() async {
    // Determine the data parameter to pass to the app
    final dataUrl = Uri.base.queryParameters['data'] ?? '';
    final intentUrl = 'quizdy://open?data=$dataUrl';

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Intent approach as a fallback or standard deep link
      final androidIntentUrl =
          'intent://${Uri.base.host}${Uri.base.path}?data=$dataUrl#Intent;scheme=https;package=es.victorcarreras.quiz_app;end';
      if (await canLaunchUrlString(androidIntentUrl)) {
        await launchUrlString(androidIntentUrl);
        return;
      }
    }

    // Generic deep link attempt (for iOS, Desktop or if intent fails)
    try {
      await launchUrlString(intentUrl);
    } catch (e) {
      debugPrint('Failed to launch native app link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Material(
          color: theme.colorScheme.primaryContainer,
          elevation: 2,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _isVisible = false),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        'images/pictorial_mark.svg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quizdy',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.openInQuizdyApp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withAlpha(200),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _openInApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(l10n.open),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
