import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../../blocs/raffle_bloc/raffle_state.dart';
import '../../../../domain/models/raffle/raffle_session.dart';

class ParticipantListWidget extends StatelessWidget {
  const ParticipantListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RaffleBloc, RaffleState>(
      builder: (context, state) {
        RaffleSession? session;

        if (state is RaffleLoaded) {
          session = state.session;
        } else if (state is RaffleWinnerSelected) {
          session = state.session;
        } else if (state is RaffleSelecting) {
          session = state.session;
        }

        if (session == null || !session.hasParticipants) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noParticipants,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.addParticipantsHint,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final activeParticipants = session.activeParticipants;
        final inactiveParticipants = session.participants
            .where((p) => !p.isActive)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.totalParticipants(session.totalParticipants),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.activeVsWinners(
                      activeParticipants.length,
                      session.winnersCount,
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Participants list
            Expanded(
              child: ListView(
                children: [
                  if (activeParticipants.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)!.activeParticipants,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...activeParticipants.map(
                      (participant) => Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.person,
                            color: Colors.green,
                          ),
                          title: Text(participant.name),
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (inactiveParticipants.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.alreadySelected,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...inactiveParticipants.map(
                      (participant) => Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        color: Colors.grey[100],
                        child: ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.person_off,
                            color: Colors.grey,
                          ),
                          title: Text(
                            participant.name,
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
