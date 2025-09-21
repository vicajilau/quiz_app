import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../blocs/raffle_bloc/raffle_event.dart';
import '../../blocs/raffle_bloc/raffle_state.dart';
import 'widgets/participant_input_widget.dart';
import 'widgets/participant_list_widget.dart';
import 'widgets/raffle_controls_widget.dart';
import 'widgets/winner_dialog.dart';

class RaffleScreen extends StatelessWidget {
  const RaffleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RaffleScreenContent();
  }
}

class _RaffleScreenContent extends StatelessWidget {
  const _RaffleScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorteo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Winners history button
          BlocBuilder<RaffleBloc, RaffleState>(
            builder: (context, state) {
              bool hasWinners = false;
              if (state is RaffleLoaded) {
                hasWinners = state.session.hasWinners;
              } else if (state is RaffleWinnerSelected) {
                hasWinners = state.session.hasWinners;
              }

              return IconButton(
                onPressed: hasWinners
                    ? () => context.go('/raffle/winners')
                    : null,
                icon: Icon(
                  Icons.emoji_events,
                  color: hasWinners ? Colors.amber : Colors.grey,
                ),
                tooltip: 'Ver ganadores',
              );
            },
          ),
          // Reset raffle button
          IconButton(
            onPressed: () => _showResetDialog(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar sorteo',
          ),
        ],
      ),
      body: BlocListener<RaffleBloc, RaffleState>(
        listener: (context, state) {
          if (state is RaffleWinnerSelected) {
            _showWinnerDialog(context, state.selectedWinner, state.session);
          } else if (state is RaffleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout: single column on mobile, two columns on larger screens
            final isWideScreen = constraints.maxWidth > 800;

            if (isWideScreen) {
              return _buildWideLayout(context);
            } else {
              return _buildNarrowLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Left side: Input and controls
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Lista de Participantes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Expanded(child: ParticipantInputWidget()),
                const SizedBox(height: 16),
                const RaffleControlsWidget(),
              ],
            ),
          ),
        ),
        Container(width: 1, color: Colors.grey[300]),
        // Right side: Participant list
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Participantes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Expanded(child: ParticipantListWidget()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Lista de Participantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: const ParticipantInputWidget()),
          const SizedBox(height: 24),
          const RaffleControlsWidget(),
          const SizedBox(height: 24),
          const Text(
            'Participantes Activos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: const ParticipantListWidget()),
        ],
      ),
    );
  }

  void _showWinnerDialog(BuildContext context, String winner, dynamic session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WinnerDialog(
        winnerName: winner,
        session: session,
        onRepeatRaffle: () {
          Navigator.of(dialogContext).pop();
          context.read<RaffleBloc>().add(ConfirmWinner(winner));
        },
        onFinishRaffle: () {
          Navigator.of(dialogContext).pop();
          context.read<RaffleBloc>().add(ConfirmWinner(winner));
          context.go('/raffle/winners');
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar Sorteo'),
        content: const Text(
          '¿Estás seguro de que quieres reiniciar el sorteo? Se perderán todos los participantes y ganadores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RaffleBloc>().add(ResetRaffle());
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}
