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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/ai_assistant_theme.dart';

class CollapsibleGenerationConfig extends StatefulWidget {
  final Widget child;
  final VoidCallback? onExpand;

  const CollapsibleGenerationConfig({
    super.key,
    required this.child,
    this.onExpand,
  });

  @override
  State<CollapsibleGenerationConfig> createState() =>
      _CollapsibleGenerationConfigState();
}

class _CollapsibleGenerationConfigState
    extends State<CollapsibleGenerationConfig> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final aiTheme = context.aiAssistantTheme;

    final borderColor = aiTheme.selectorBorderColor;
    final headerBgColor = aiTheme.selectorHeaderBg;
    final bodyBgColor = aiTheme.selectorContentBg;
    final iconColor = aiTheme.selectorLabelColor;
    final titleColor = aiTheme.selectorTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                widget.onExpand?.call();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: _isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 18, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.generationConfigurationTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 18,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
        _isExpanded
            ? Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  color: bodyBgColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: Border(
                    left: BorderSide(color: borderColor),
                    right: BorderSide(color: borderColor),
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: widget.child,
              )
            : const SizedBox(width: double.infinity),
      ],
    );
  }
}
