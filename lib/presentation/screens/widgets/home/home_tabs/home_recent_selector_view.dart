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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';
import 'package:quizdy/domain/models/recent_quiz/recent_quiz.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_cubit.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_recent_card.dart';
import 'package:quizdy/presentation/utils/date_formatter.dart';

class HomeRecentSelectorView extends StatelessWidget {
  final List<RecentQuiz> items;
  final ValueChanged<RecentQuiz> onTapRecent;
  final VoidCallback onLoadFile;
  final VoidCallback onCreateFile;

  const HomeRecentSelectorView({
    super.key,
    required this.items,
    required this.onTapRecent,
    required this.onLoadFile,
    required this.onCreateFile,
  });

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.fileClock,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.homeRecentSectionTitle,
                style: TextStyle(
                  color: homeTheme.textPrimaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeCardLoadFileDesc,
                style: TextStyle(
                  color: homeTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 96,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return HomeRecentCard(
                        title: item.title,
                        progress: item.progress,
                        lastOpenedText: DateFormatter.formatLastOpened(
                          context,
                          item.lastOpened,
                        ),
                        onTap: () => onTapRecent(item),
                        onDelete: () {
                          context.read<RecentQuizzesCubit>().deleteRecentQuiz(
                            item.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onLoadFile,
                    icon: const Icon(LucideIcons.upload, size: 16),
                    label: Text(l10n.homeCardLoadFileTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: onCreateFile,
                    icon: const Icon(LucideIcons.plusCircle, size: 16),
                    label: Text(l10n.homeCardCreateQuizTitle),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
