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
import 'package:genui/genui.dart';
import 'package:genui_annotations/genui_annotations.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

part 'pros_cons_component.genui.g.dart';

@GenerativeUI(name: 'pros_cons')
class ProsConsComponent extends StatelessWidget {
  final List<dynamic> pros;
  final List<dynamic> cons;

  const ProsConsComponent({super.key, required this.pros, required this.cons});

  @override
  Widget build(BuildContext context) {
    final parsedPros = pros.map((e) => e.toString()).toList();
    final parsedCons = cons.map((e) => e.toString()).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildList(
                  context,
                  AppLocalizations.of(context)!.studyComponentAdvantages,
                  parsedPros,
                  true,
                ),
                const SizedBox(height: 16),
                _buildList(
                  context,
                  AppLocalizations.of(context)!.studyComponentLimitations,
                  parsedCons,
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
                    parsedPros,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildList(
                    context,
                    AppLocalizations.of(context)!.studyComponentLimitations,
                    parsedCons,
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
                    Expanded(child: QuizdyMarkdown(data: item)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
