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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';
import 'package:quizdy/domain/models/recent_quiz/recent_quiz.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_cubit.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_state.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_action_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_recent_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_feedback_card.dart';
import 'package:quizdy/presentation/screens/widgets/home/home_global_drag_hint.dart';
import 'package:quizdy/presentation/utils/date_formatter.dart';

class HomeInicioTabView extends StatefulWidget {
  final bool showFeedbackBanner;
  final VoidCallback onOpenFeedbackForm;
  final VoidCallback onStartStudyModeWithAI;
  final VoidCallback onGenerateQuestionsWithAI;
  final VoidCallback onCreateQuizFile;
  final VoidCallback onLoadFile;
  final ValueChanged<RecentQuiz> onTapRecent;
  final VoidCallback onShowSettings;
  final QuizFile? activeQuiz;

  const HomeInicioTabView({
    super.key,
    required this.showFeedbackBanner,
    required this.onOpenFeedbackForm,
    required this.onStartStudyModeWithAI,
    required this.onGenerateQuestionsWithAI,
    required this.onCreateQuizFile,
    required this.onLoadFile,
    required this.onTapRecent,
    required this.onShowSettings,
    this.activeQuiz,
  });

  @override
  State<HomeInicioTabView> createState() => _HomeInicioTabViewState();
}

class _HomeInicioTabViewState extends State<HomeInicioTabView> {
  bool _showAllRecents = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final homeTheme = context.homeTheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildTopBar(context, isMobile, homeTheme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<RecentQuizzesCubit>().loadRecentQuizzes();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 40.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_showAllRecents) ...[
                        // Welcome row
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.homeWelcomeTitle,
                              style: TextStyle(
                                color: homeTheme.textPrimaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.homeWelcomeSubtitle,
                              style: TextStyle(
                                color: homeTheme.textSecondaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recent studies
                      BlocBuilder<RecentQuizzesCubit, RecentQuizzesState>(
                        builder: (context, recentState) {
                          if (recentState is RecentQuizzesLoaded) {
                            final recents = recentState.recentQuizzes;
                            if (recents.isEmpty && !_showAllRecents) {
                              return const SizedBox.shrink();
                            }

                            final listToDisplay = _showAllRecents
                                ? recents
                                : recents.take(3).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRecentHeader(
                                  context,
                                  recents.length,
                                  homeTheme,
                                ),
                                const SizedBox(height: 16),
                                _buildRecentCardsGrid(context, listToDisplay),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      if (!_showAllRecents) ...[
                        // AI actions row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final useColumn = constraints.maxWidth < 600;
                            final cardWidgets = [
                              HomeActionCard(
                                title: AppLocalizations.of(
                                  context,
                                )!.homeCardStudyAiTitle,
                                description: AppLocalizations.of(
                                  context,
                                )!.homeCardStudyAiDesc,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.homeCardStudyAiBadge,
                                backgroundColor: homeTheme.studyAiCardColor,
                                icon: LucideIcons.sparkles,
                                isPrimary: true,
                                onTap: widget.onStartStudyModeWithAI,
                              ),
                              HomeActionCard(
                                title: AppLocalizations.of(
                                  context,
                                )!.homeCardQuizAiTitle,
                                description: AppLocalizations.of(
                                  context,
                                )!.homeCardQuizAiDesc,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.homeCardQuizAiBadge,
                                backgroundColor: homeTheme.quizAiCardColor,
                                icon: LucideIcons.graduation_cap,
                                isPrimary: true,
                                onTap: widget.onGenerateQuestionsWithAI,
                              ),
                            ];

                            return useColumn
                                ? Column(
                                    children: cardWidgets
                                        .map(
                                          (c) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: c,
                                          ),
                                        )
                                        .toList(),
                                  )
                                : Row(
                                    children: cardWidgets
                                        .map(
                                          (c) => Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: c,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Manual actions row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final useColumn = constraints.maxWidth < 600;
                            final cardWidgets = [
                              HomeActionCard(
                                title: AppLocalizations.of(
                                  context,
                                )!.homeCardCreateQuizTitle,
                                description: AppLocalizations.of(
                                  context,
                                )!.homeCardCreateQuizDesc,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.homeCardCreateQuizBadge,
                                backgroundColor: homeTheme.cardBackgroundColor,
                                icon: LucideIcons.circle_plus,
                                isPrimary: false,
                                accentColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onTap: widget.onCreateQuizFile,
                              ),
                              HomeActionCard(
                                title: AppLocalizations.of(
                                  context,
                                )!.homeCardLoadFileTitle,
                                description: AppLocalizations.of(
                                  context,
                                )!.homeCardLoadFileDesc,
                                badgeText: AppLocalizations.of(
                                  context,
                                )!.homeCardLoadFileBadge,
                                backgroundColor: homeTheme.cardBackgroundColor,
                                icon: LucideIcons.upload,
                                isPrimary: false,
                                accentColor: homeTheme.textSecondaryColor,
                                onTap: widget.onLoadFile,
                              ),
                            ];

                            return useColumn
                                ? Column(
                                    children: cardWidgets
                                        .map(
                                          (c) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: c,
                                          ),
                                        )
                                        .toList(),
                                  )
                                : Row(
                                    children: cardWidgets
                                        .map(
                                          (c) => Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: c,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Global drag hint card
                        const HomeGlobalDragHint(),
                        const SizedBox(height: 24),

                        // Feedback card
                        if (widget.showFeedbackBanner) ...[
                          HomeFeedbackCard(onTap: widget.onOpenFeedbackForm),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    bool isMobile,
    HomeTheme homeTheme,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: homeTheme.mainBackgroundColor,
        border: Border(
          bottom: BorderSide(color: homeTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.homeMenuInicio,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: homeTheme.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMobile)
            IconButton(
              icon: Icon(LucideIcons.settings, color: homeTheme.borderColor),
              onPressed: widget.onShowSettings,
            ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader(
    BuildContext context,
    int totalCount,
    HomeTheme homeTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_showAllRecents)
              IconButton(
                icon: Icon(
                  LucideIcons.arrow_left,
                  color: homeTheme.borderColor,
                ),
                onPressed: () {
                  setState(() {
                    _showAllRecents = false;
                  });
                },
              ),
            Text(
              AppLocalizations.of(context)!.homeRecentSectionTitle,
              style: TextStyle(
                color: homeTheme.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!_showAllRecents && totalCount > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllRecents = true;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeRecentViewAll,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevron_right,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          )
        else if (_showAllRecents)
          TextButton(
            onPressed: () {
              context.read<RecentQuizzesCubit>().clearAllRecentQuizzes();
            },
            child: Text(
              AppLocalizations.of(context)!.homeClearHistoryButton,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentCardsGrid(BuildContext context, List<RecentQuiz> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 108,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isActive =
                widget.activeQuiz != null &&
                item.id ==
                    (widget.activeQuiz!.filePath ??
                        'unsaved_${widget.activeQuiz!.metadata.title.hashCode}');
            return HomeRecentCard(
              title: item.title,
              progress: item.progress,
              lastOpenedText: DateFormatter.formatLastOpened(
                context,
                item.lastOpened,
              ),
              onTap: () => widget.onTapRecent(item),
              onDelete: () {
                context.read<RecentQuizzesCubit>().deleteRecentQuiz(item.id);
              },
              isActive: isActive,
            );
          },
        );
      },
    );
  }
}
