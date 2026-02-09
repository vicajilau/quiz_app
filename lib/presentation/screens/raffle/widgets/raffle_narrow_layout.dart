import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/participant_input_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/participant_list_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/raffle_controls_widget.dart';

class RaffleNarrowLayout extends StatelessWidget {
  const RaffleNarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.participantListTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const ParticipantInputWidget(),
          const SizedBox(height: 24),
          const RaffleControlsWidget(),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.activeParticipants,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const ParticipantListWidget(),
        ],
      ),
    );
  }
}
