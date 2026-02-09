import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/raffle/raffle_winner.dart';
import 'package:quiz_app/domain/models/raffle/raffle_logo.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_state.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/logo_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/winners_empty_state.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/winners_list_widget.dart';
import 'package:quiz_app/routes/app_router.dart';


class WinnersScreen extends StatelessWidget {
  const WinnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RaffleBloc, RaffleState>(
      builder: (context, state) {
        // Extract logo from different state types
        RaffleLogo? logo;
        if (state is RaffleLoaded) {
          logo = state.session.logo;
        } else if (state is RaffleWinnerSelected) {
          logo = state.session.logo;
        }

        return Scaffold(
          appBar: AppBar(
            title: logo != null
                ? LogoWidget(
                    logo: logo,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Text(AppLocalizations.of(context)!.winnersTitle),
                  )
                : Text(AppLocalizations.of(context)!.winnersTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.raffle),
            ),
            actions: [
              IconButton(
                onPressed: () => _showShareDialog(context),
                icon: const Icon(Icons.share),
                tooltip: AppLocalizations.of(context)!.shareResults,
              ),
            ],
          ),
          body: BlocBuilder<RaffleBloc, RaffleState>(
            builder: (context, state) {
              List<RaffleWinner> winners = [];

              if (state is RaffleLoaded) {
                winners = state.session.winners;
              } else if (state is RaffleWinnerSelected) {
                winners = state.session.winners;
              }

              return winners.isEmpty
                  ? const WinnersEmptyState()
                  : WinnersListWidget(winners: winners);
            },
          ),
        );
      },
    );
  }

  void _showShareDialog(BuildContext context) {
    // Get current winners from BLoC
    List<RaffleWinner> winners = [];
    final state = context.read<RaffleBloc>().state;

    if (state is RaffleLoaded) {
      winners = state.session.winners;
    } else if (state is RaffleWinnerSelected) {
      winners = state.session.winners;
    }

    final resultsText = _generateResultsText(winners, context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
        final codeBg = isDark
            ? const Color(0xFF18181B)
            : const Color(0xFFF4F4F5);
        final codeText = isDark
            ? const Color(0xFFE4E4E7)
            : const Color(0xFF18181B);

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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.shareResultsTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
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

                Text(
                  AppLocalizations.of(context)!.raffleResultsLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: codeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 150,
                  child: SingleChildScrollView(
                    child: Text(
                      resultsText,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: codeText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await Clipboard.setData(ClipboardData(text: resultsText));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.shareSuccess,
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.share,
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
  }

  String _getPositionText(BuildContext context, int position) {
    switch (position) {
      case 1:
        return AppLocalizations.of(context)!.firstPlace;
      case 2:
        return AppLocalizations.of(context)!.secondPlace;
      case 3:
        return AppLocalizations.of(context)!.thirdPlace;
      default:
        return AppLocalizations.of(context)!.nthPlace(position);
    }
  }

  String _generateResultsText(
    List<RaffleWinner> winners,
    BuildContext context,
  ) {
    if (winners.isEmpty) return AppLocalizations.of(context)!.noWinnersToShare;

    final buffer = StringBuffer();
    buffer.writeln(AppLocalizations.of(context)!.raffleResultsHeader);
    buffer.writeln();

    for (final winner in winners) {
      buffer.writeln(
        '${AppLocalizations.of(context)!.placeLabel(_getPositionText(context, winner.position))}: ${winner.name}',
      );
    }

    buffer.writeln();
    buffer.writeln(AppLocalizations.of(context)!.totalWinners(winners.length));

    return buffer.toString();
  }
}
