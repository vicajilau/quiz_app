import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/dialogs/ai_generate_questions_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/import_questions_dialog.dart';

/// A mixin that handles AI question generation for [FileLoadedScreen].
///
/// This mixin provides functionality to generate questions using AI services (OpenAI, Gemini)
/// and add them to the current quiz.
mixin AiGenerationMixin<T extends StatefulWidget> on State<T> {
  /// The currently cached [QuizFile] that is being edited.
  QuizFile get cachedQuizFile;

  /// Updates the cached [QuizFile] with a new instance.
  ///
  /// This method typically calls `setState` in the consuming widget.
  void updateQuizFile(QuizFile newFile);

  /// Triggers a check to see if the file has unsaved changes.
  void checkFileChange();

  /// Handles generating questions with AI.
  ///
  /// Checks if AI is enabled and if API keys are configured.
  /// Opens a configuration dialog to set generation parameters.
  /// Calls the AI service to generate questions and adds them to the quiz file.
  Future<void> generateQuestionsWithAI() async {
    try {
      final isAIactivated = await ConfigurationService.instance
          .getAIAssistantEnabled();

      // Check if AI is enabled and has API keys
      final openaiKey = await ConfigurationService.instance.getOpenAIApiKey();
      final geminiKey = await ConfigurationService.instance.getGeminiApiKey();

      if (!isAIactivated) {
        if (mounted) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.aiAssistantDisabled),
                content: Text(AppLocalizations.of(context)!.enableAiAssistant),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(AppLocalizations.of(context)!.acceptButton),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      if ((openaiKey?.isEmpty ?? true) && (geminiKey?.isEmpty ?? true)) {
        if (mounted) {
          context.presentSnackBar(
            AppLocalizations.of(context)!.aiApiKeyRequired,
          );
        }
        return;
      }

      // Show AI generation dialog
      if (!mounted) return;
      final config = await showDialog<AiQuestionGenerationConfig>(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) => const AiGenerateQuestionsDialog(),
      );

      if (config == null || !mounted) return;

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Generate questions with AI
        final aiService = AiQuestionGenerationService();
        final localizations = AppLocalizations.of(context)!;
        final generatedQuestions = await aiService.generateQuestions(
          config,
          localizations: localizations,
        );

        // Close loading dialog
        if (mounted) {
          context.pop();
        }

        if (generatedQuestions.isEmpty) {
          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.aiGenerationFailed,
            );
          }
          return;
        }

        if (cachedQuizFile.questions.isEmpty) {
          updateQuizFile(
            cachedQuizFile.copyWith(questions: [...generatedQuestions]),
          );
          checkFileChange();
          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(
                context,
              )!.questionsImportedSuccess(generatedQuestions.length),
            );
          }
          return;
        }

        // Show import dialog to choose position
        if (!mounted) return;
        final questionsPosition = await showDialog<QuestionsPosition>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ImportQuestionsDialog(
            questionCount: generatedQuestions.length,
            fileName: AppLocalizations.of(context)!.aiGeneratedQuestions,
          ),
        );

        if (questionsPosition != null && mounted) {
          final updatedQuestions = [...cachedQuizFile.questions];
          if (questionsPosition == QuestionsPosition.beginning) {
            updatedQuestions.insertAll(0, generatedQuestions);
          } else {
            updatedQuestions.addAll(generatedQuestions);
          }

          updateQuizFile(cachedQuizFile.copyWith(questions: updatedQuestions));
          checkFileChange();

          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(
                context,
              )!.questionsImportedSuccess(generatedQuestions.length),
            );
          }
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) {
          context.pop();

          context.presentSnackBar(
            AppLocalizations.of(
              context,
            )!.aiGenerationError(e.toString().cleanExceptionPrefix()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.presentSnackBar('Error: ${e.toString()}');
      }
    }
  }
}
