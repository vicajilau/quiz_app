import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_event.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/confirm_dialog_colors_extension.dart';

/// Shows a confirmation dialog to clear all winners from the raffle.
///
/// Returns a [Future<bool>] that completes with:
/// - `true` if the user confirmed and winners were cleared
/// - `false` if the user canceled the operation
Future<bool> showClearWinnersDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colors = context.appColors;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.resetWinnersConfirmTitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.title,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      fixedSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(Icons.close, size: 20, color: colors.subtitle),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              Text(
                AppLocalizations.of(context)!.resetWinnersConfirmMessage,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: colors.subtitle,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.reset,
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
        ),
      );
    },
  );

  if (confirmed == true && context.mounted) {
    context.read<RaffleBloc>().add(ClearWinners());
    return true;
  }

  return false;
}
