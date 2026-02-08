import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

class ExamTimerWidget extends StatefulWidget {
  final int initialDurationMinutes;
  final VoidCallback onTimeExpired;
  final bool isQuizCompleted;

  const ExamTimerWidget({
    super.key,
    required this.initialDurationMinutes,
    required this.onTimeExpired,
    this.isQuizCompleted = false,
  });

  @override
  State<ExamTimerWidget> createState() => _ExamTimerWidgetState();
}

class _ExamTimerWidgetState extends State<ExamTimerWidget>
    with TickerProviderStateMixin {
  Timer? _examTimer;
  Duration? _remainingTime;
  late AnimationController _timerAnimationController;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _remainingTime = Duration(minutes: widget.initialDurationMinutes);
    if (!widget.isQuizCompleted && widget.initialDurationMinutes > 0) {
      _startExamTimer();
    }
  }

  @override
  void didUpdateWidget(ExamTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Stop timer when quiz is completed
    if (!oldWidget.isQuizCompleted && widget.isQuizCompleted) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _stopTimer() {
    _examTimer?.cancel();
    _timerAnimationController.stop();
  }

  void _startExamTimer() {
    // If minutes is 0 or less, don't start timer as it implies no limit
    if (widget.initialDurationMinutes <= 0) return;

    if (_remainingTime == null) return;

    _timerAnimationController.repeat();

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingTime == null) return;

      if (_remainingTime!.inSeconds <= 0) {
        _handleTimeExpired();
        timer.cancel(); // Also cancel the timer here
        return;
      }

      setState(() {
        _remainingTime = _remainingTime! - const Duration(seconds: 1);
      });
    });
  }

  void _handleTimeExpired() {
    _stopTimer();

    if (!mounted) return;

    // Show time expired dialog
    _showTimeExpiredDialog();
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF18181B);
        final subTextColor = isDark
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF71717A);
        final borderColor = isDark
            ? const Color(0xFF3F3F46)
            : const Color(0xFFE4E4E7);
        final primaryColor = const Color(0xFF8B5CF6);

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Title only, no close button)
                Text(
                  AppLocalizations.of(context)!.examTimeExpiredTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  AppLocalizations.of(context)!.examTimeExpiredMessage,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: subTextColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Finish Button
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    widget.onTimeExpired();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.finish),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime == null || widget.initialDurationMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final hours = _remainingTime!.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime!.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime!.inSeconds % 60).toString().padLeft(2, '0');

    // Determine color based on remaining time (e.g. red if < 5 mins)
    final bool isLowTime = _remainingTime!.inMinutes < 5;
    final primaryColor = Theme.of(context).primaryColor;
    final color = isLowTime ? Colors.red : primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: widget.isQuizCompleted
                ? const AlwaysStoppedAnimation(0)
                : _timerAnimationController,
            child: Icon(Icons.hourglass_empty, size: 16, color: color),
          ),
          const SizedBox(width: 6),
          // We need a context for localization to work properly, passing dynamic strings
          Text(
            // Assuming remainingTime format "%s:%s:%s" is supported by arb,
            // or we construct the string manually if the arb expects variables.
            // Based on previous view_file, 'remainingTime' key maps to something taking args.
            // Let's assume standard Arb support or just use string interpolation if key relies on it.
            // Checking arb file earlier: "remainingTime": "Time remaining: {hours}:{minutes}:{seconds}"
            AppLocalizations.of(
              context,
            )!.remainingTime(hours, minutes, seconds),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
