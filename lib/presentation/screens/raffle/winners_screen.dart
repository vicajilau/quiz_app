import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/raffle/raffle_winner.dart';
import '../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../blocs/raffle_bloc/raffle_state.dart';

class WinnersScreen extends StatelessWidget {
  const WinnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.winnersTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/raffle'),
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
              ? _buildEmptyState()
              : _buildWinnersList(winners, context);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noWinnersYet,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.performRaffleToSeeWinners,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/raffle'),
              icon: const Icon(Icons.casino),
              label: Text(AppLocalizations.of(context)!.goToRaffle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersList(List<RaffleWinner> winners, BuildContext context) {
    return Column(
      children: [
        // Header with summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[50]!, Colors.orange[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.raffleCompleted,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.winnersSelectedCount(winners.length),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Winners list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: winners.length,
            itemBuilder: (context, index) {
              final winner = winners[index];
              return _buildWinnerCard(winner, index, context);
            },
          ),
        ),

        // Footer with action buttons
        Builder(
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/raffle'),
                  icon: const Icon(Icons.casino),
                  label: Text(AppLocalizations.of(context)!.newRaffle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerCard(
    RaffleWinner winner,
    int index,
    BuildContext context,
  ) {
    final position = winner.position;
    Color cardColor;
    IconData icon;
    Color iconColor;

    // Different styling for different positions
    switch (position) {
      case 1:
        cardColor = Colors.amber[50]!;
        icon = Icons.looks_one;
        iconColor = Colors.amber;
        break;
      case 2:
        cardColor = Colors.grey[100]!;
        icon = Icons.looks_two;
        iconColor = Colors.grey[600]!;
        break;
      case 3:
        cardColor = Colors.orange[50]!;
        icon = Icons.looks_3;
        iconColor = Colors.orange;
        break;
      default:
        cardColor = Colors.blue[50]!;
        icon = Icons.emoji_events;
        iconColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.2),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          winner.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)!.placeLabel(_getPositionText(context, position))} • ${_formatTime(winner.selectedAt)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: position <= 3
            ? Icon(Icons.emoji_events, color: iconColor, size: 28)
            : null,
      ),
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.shareResultsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.raffleResultsLabel),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                resultsText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          TextButton(
            onPressed: () {
              // Here you could implement actual sharing functionality
              // For now, we'll just copy to clipboard or show a message
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.shareNotImplemented,
                  ),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.share),
          ),
        ],
      ),
    );
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
