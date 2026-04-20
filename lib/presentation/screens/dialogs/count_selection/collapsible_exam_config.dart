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

class CollapsibleExamConfig extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const CollapsibleExamConfig({
    super.key,
    required this.isDark,
    required this.child,
  });

  @override
  State<CollapsibleExamConfig> createState() => _CollapsibleExamConfigState();
}

class _CollapsibleExamConfigState extends State<CollapsibleExamConfig> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);
    final headerBgColor = widget.isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final bodyBgColor = widget.isDark
        ? const Color(0xFF1E1E22)
        : const Color(0xFFFAFAFA);
    final iconColor = widget.isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final titleColor = widget.isDark ? Colors.white : const Color(0xFF18181B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
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
                Expanded(
                  child: Row(
                    children: [
                      Icon(LucideIcons.settings, size: 18, color: iconColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.examConfigurationTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
          child: _isExpanded
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
        ),
      ],
    );
  }
}
