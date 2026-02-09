import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/participant_input_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/participant_list_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/raffle_controls_widget.dart';

class RaffleWideLayout extends StatelessWidget {
  const RaffleWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Input and controls
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.participantListTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ParticipantInputWidget(),
                  const SizedBox(height: 16),
                  const RaffleControlsWidget(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(width: 1, color: Colors.grey),
            const SizedBox(width: 16),
            // Right side: Participant list
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.participants,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ParticipantListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
