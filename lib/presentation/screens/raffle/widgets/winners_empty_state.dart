import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:quiz_app/core/theme/app_theme.dart';

class WinnersEmptyState extends StatelessWidget {
  const WinnersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: AppTheme.zinc400,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noWinnersYet,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.zinc600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.performRaffleToSeeWinners,
            style: const TextStyle(fontSize: 16, color: AppTheme.zinc500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.raffle),
                icon: const Icon(Icons.casino),
                label: Text(
                  AppLocalizations.of(context)!.goToRaffle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
