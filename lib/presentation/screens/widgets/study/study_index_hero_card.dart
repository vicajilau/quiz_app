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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/repositories/srs/srs_repository.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

class StudyIndexHeroCard extends StatelessWidget {
  final StudyExecutionState state;
  final AppLocalizations localizations;
  final QuizFile? quizFile;

  const StudyIndexHeroCard({
    super.key,
    required this.state,
    required this.localizations,
    this.quizFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final statCardBg = isDark ? const Color(0xFF1F1F23) : AppTheme.zinc100;
    final statLabelColor = isDark ? AppTheme.zinc500 : AppTheme.zinc400;
    final completedValueColor = isDark
        ? const Color(0xFF5EEAD4)
        : AppTheme.secondaryColor;

    int correctQuestionsCount = 0;
    int totalQuestionsCount = 0;
    double learnedPercentage = 0.0;

    if (quizFile != null) {
      final chunkIds = state.chunks.map((c) => c.id).toSet();
      final questions = quizFile!.questions
          .where(
            (q) =>
                q.isEnabled &&
                q.studySectionId != null &&
                chunkIds.contains(q.studySectionId),
          )
          .toList();

      if (questions.isNotEmpty) {
        totalQuestionsCount = questions.length;
        final srsRepository = ServiceLocator.getIt<SrsRepository>();
        final fileId = quizFile!.filePath ?? quizFile!.metadata.title;

        for (final question in questions) {
          final identity = question.identityHash.toString();
          final metadata = srsRepository.getMetadataForQuestion(
            identity,
            fileId,
          );
          if (metadata.repetition > 0) {
            correctQuestionsCount++;
          }
        }
        learnedPercentage = (correctQuestionsCount / totalQuestionsCount) * 100;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.studyScreenStudyGuide.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            state.documentTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        if (state.documentSummary != null &&
            state.documentSummary!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            state.documentSummary!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: summaryColor,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatCard(
                context,
                value: '${state.chunks.length}',
                label: localizations.studyScreenSections,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                value: '${state.progressPercentage.toStringAsFixed(0)}%',
                label: localizations.studyScreenCoverage,
                valueColor: AppTheme.primaryColor,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                value: '${state.completedChunks}/${state.chunks.length}',
                label: localizations.studyScreenCompleted,
                valueColor: completedValueColor,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
            ],
          ),
        ),
        if (totalQuestionsCount > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statCardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2D2D33) : AppTheme.zinc200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.brain,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.studyScreenLearnedContent,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${learnedPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: learnedPercentage / 100,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? const Color(0xFF2D2D33)
                        : AppTheme.zinc200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.studyScreenLearnedQuestionsCount(
                    correctQuestionsCount,
                    totalQuestionsCount,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.zinc500 : AppTheme.zinc600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state.chunks.any(
          (c) =>
              c.status != StudyChunkState.completed &&
              c.status != StudyChunkState.downloaded,
        )) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).extension<CustomColors>()!.warningContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.triangle_alert,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).extension<CustomColors>()!.onWarningContainer,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    localizations.studyScreenPendingSections,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).extension<CustomColors>()!.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: QuizdyButton(
              type: QuizdyButtonType.primary,
              title: localizations.studyScreenDownloadAllButton,
              icon: LucideIcons.download,
              expanded: true,
              onPressed: () {
                _showDownloadingDialog(context);
                context.read<StudyExecutionBloc>().add(
                  const DownloadAllStudyChunksRequested(),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    Color? valueColor,
    required Color cardBg,
    required Color labelColor,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadingDialog(BuildContext context) {
    final studyExecutionBloc = context.read<StudyExecutionBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _DownloadAllDialog(
          bloc: studyExecutionBloc,
          localizations: localizations,
        );
      },
    );
  }
}

class _DownloadAllDialog extends StatefulWidget {
  final StudyExecutionBloc bloc;
  final AppLocalizations localizations;

  const _DownloadAllDialog({required this.bloc, required this.localizations});

  @override
  State<_DownloadAllDialog> createState() => _DownloadAllDialogState();
}

class _DownloadAllDialogState extends State<_DownloadAllDialog> {
  StreamSubscription? _doneSubscription;

  @override
  void initState() {
    super.initState();
    _doneSubscription = widget.bloc.stream.listen(
      (state) {
        if (!state.isDownloadingAll) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      onDone: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _doneSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
        builder: (context, state) {
          final total = state.chunks.length;
          final completed = state.chunks
              .where(
                (c) =>
                    c.status == StudyChunkState.completed ||
                    c.status == StudyChunkState.downloaded,
              )
              .length;
          final percent = total > 0 ? (completed / total) : 0.0;

          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    LucideIcons.download,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  _LoadingDotsText(
                    baseText: _stripTrailingDots(
                      widget.localizations.downloadingSectionsTitle,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      color: AppTheme.primaryColor,
                      backgroundColor: AppTheme.zinc100,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      widget.localizations.downloadingSectionsProgress(
                        completed,
                        total,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.zinc400
                            : AppTheme.zinc600,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!widget.bloc.isClosed) {
                      widget.bloc.add(const CancelDownloadAllRequested());
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    widget.localizations.cancelButton.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _stripTrailingDots(String text) {
    while (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }
}

class _LoadingDotsText extends StatefulWidget {
  final String baseText;
  final TextStyle? style;

  const _LoadingDotsText({required this.baseText, this.style});

  @override
  State<_LoadingDotsText> createState() => _LoadingDotsTextState();
}

class _LoadingDotsTextState extends State<_LoadingDotsText> {
  late Timer _timer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: widget.baseText),
          TextSpan(text: '.' * _dotCount),
          TextSpan(
            text: '.' * (3 - _dotCount),
            style: const TextStyle(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
