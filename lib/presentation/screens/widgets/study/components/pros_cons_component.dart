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
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class ProsConsComponent extends StatelessWidget {
  final StudyComponent element;

  const ProsConsComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final items = element.props['items'] as Map<String, dynamic>?;
    final prosList = items?['pros'] as List<dynamic>? ?? [];
    final consList = items?['cons'] as List<dynamic>? ?? [];

    final pros = prosList.map((e) => e.toString()).toList();
    final cons = consList.map((e) => e.toString()).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildList(
                  context,
                  AppLocalizations.of(context)!.studyComponentAdvantages,
                  pros,
                  true,
                ),
                const SizedBox(height: 16),
                _buildList(
                  context,
                  AppLocalizations.of(context)!.studyComponentLimitations,
                  cons,
                  false,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildList(
                    context,
                    AppLocalizations.of(context)!.studyComponentAdvantages,
                    pros,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildList(
                    context,
                    AppLocalizations.of(context)!.studyComponentLimitations,
                    cons,
                    false,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String title,
    List<String> items,
    bool isPros,
  ) {
    final studyTheme = context.studyTheme;

    final backgroundColor = isPros
        ? studyTheme.prosBackground
        : studyTheme.consBackground;
    final borderColor = isPros ? studyTheme.prosBorder : studyTheme.consBorder;
    final iconColor = isPros ? studyTheme.prosIcon : studyTheme.consIcon;
    final icon = isPros ? LucideIcons.checkCircle2 : LucideIcons.xCircle;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              AppLocalizations.of(context)!.studyComponentNoItems,
              style: TextStyle(color: studyTheme.cardSubtitle),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: MarkdownWidget(data: item)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
