import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/presentation/widgets/network_image_widget.dart';
import '../../../core/l10n/app_localizations.dart';
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
    return BlocBuilder<RaffleBloc, RaffleState>(
      builder: (context, state) {
        Uint8List? logoUrl;
        if (state is RaffleLoaded) {
          logoUrl = state.session.logoUrl;
        } else if (state is RaffleWinnerSelected) {
          logoUrl = state.session.logoUrl;
        }

        return Scaffold(
          appBar: AppBar(
            title: logoUrl != null && logoUrl.isNotEmpty
                ? Container(
                    height: 40,
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: NetworkImageWidget(
                      imageUrl: logoUrl,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('AppBar logo failed to load: $error');
                        return Text(AppLocalizations.of(context)!.raffleTitle);
                      },
                      loadingBuilder: (context) => const SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  )
                : Text(AppLocalizations.of(context)!.raffleTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            actions: [
              // Logo configuration button
              IconButton(
                onPressed: () => _showLogoSelector(context),
                icon: const Icon(Icons.image),
                tooltip: AppLocalizations.of(context)!.selectLogo,
              ),
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
                    tooltip: AppLocalizations.of(context)!.viewWinners,
                  );
                },
              ),
              // Reset raffle button
              IconButton(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.refresh),
                tooltip: AppLocalizations.of(context)!.resetRaffleTitle,
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
      },
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
                Text(
                  AppLocalizations.of(context)!.participantListTitle,
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
                Text(
                  AppLocalizations.of(context)!.participants,
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
          Text(
            AppLocalizations.of(context)!.participantListTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: const ParticipantInputWidget()),
          const SizedBox(height: 24),
          const RaffleControlsWidget(),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.activeParticipants,
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
        title: Text(AppLocalizations.of(context)!.resetRaffleTitle),
        content: Text(AppLocalizations.of(context)!.resetRaffleConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RaffleBloc>().add(ResetRaffle());
            },
            child: Text(AppLocalizations.of(context)!.reset),
          ),
        ],
      ),
    );
  }

  void _showLogoSelector(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    final logoContent = result?.files.first.bytes;

    if (logoContent != null && context.mounted) {
      context.read<RaffleBloc>().add(SetRaffleLogo(logoContent));
    }
  }
}
