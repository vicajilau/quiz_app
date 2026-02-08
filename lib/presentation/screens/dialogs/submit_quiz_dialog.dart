import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';

class SubmitQuizDialog {
  static void show(BuildContext context, QuizExecutionBloc bloc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Design Tokens
        final dialogBg = isDark
            ? const Color(0xFF27272A)
            : const Color(0xFFFFFFFF);
        final titleColor = isDark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF000000);
        final contentColor = isDark
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF71717A);
        final closeBtnBg = isDark
            ? const Color(0xFF3F3F46)
            : const Color(0xFFF4F4F5);
        final closeBtnIcon = isDark
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF71717A);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Title + Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.finishQuiz,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: closeBtnBg,
                        fixedSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      icon: Icon(Icons.close, size: 20, color: closeBtnIcon),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Text(
                  AppLocalizations.of(context)!.finishQuizConfirmation,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: contentColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Actions (Stacked buttons)
                Column(
                  children: [
                    // Finish Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          bloc.add(QuizSubmitted());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.finish,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
