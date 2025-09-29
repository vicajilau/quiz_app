import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/logo_widget.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/raffle/raffle_logo.dart';
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
        RaffleLogo? logo;
        if (state is RaffleLoaded) {
          logo = state.session.logo;
        } else if (state is RaffleWinnerSelected) {
          logo = state.session.logo;
        } else if (state is RaffleWarning) {
          logo = state.session.logo;
        }

        return Scaffold(
          appBar: AppBar(
            title: Tooltip(
              message: AppLocalizations.of(context)!.selectLogo,
              child: InkWell(
                onTap: () => _showLogoSelector(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: logo != null
                      ? Container(
                          height: 40,
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: LogoWidget(
                            logo: logo,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('AppBar logo failed to load: $error');
                              return Text(
                                AppLocalizations.of(context)!.raffleTitle,
                              );
                            },
                            loadingBuilder: (context) => const SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.raffleTitle),
                ),
              ),
            ),
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
                  } else if (state is RaffleWarning) {
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
              } else if (state is RaffleWarning) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
                // Return to loaded state after showing warning
                context.read<RaffleBloc>().add(DismissWarning());
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
    // Get current logo state
    RaffleLogo? currentLogo;
    final currentState = context.read<RaffleBloc>().state;
    if (currentState is RaffleLoaded) {
      currentLogo = currentState.session.logo;
    } else if (currentState is RaffleWinnerSelected) {
      currentLogo = currentState.session.logo;
    } else if (currentState is RaffleWarning) {
      currentLogo = currentState.session.logo;
    }

    final hasLogo = currentLogo != null;

    // Show dialog with options
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLogo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLogo) ...[
              // Show current logo preview
              Container(
                height: 80,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LogoWidget(
                    logo: currentLogo!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, color: Colors.grey),
                    loadingBuilder: (context) =>
                        Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.logoPreview,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              AppLocalizations.of(context)!.logoUrlHint,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          // Remove logo button (only if there's a current logo)
          if (hasLogo)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<RaffleBloc>().add(RemoveRaffleLogo());
              },
              child: Text(
                AppLocalizations.of(context)!.removeLogo,
                style: TextStyle(color: Colors.red),
              ),
            ),
          // Select new logo button
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'],
                allowMultiple: false,
                withData: true,
              );

              final file = result?.files.first;
              final logoContent = file?.bytes;
              final filename = file?.name;

              if (logoContent != null && context.mounted) {
                context.read<RaffleBloc>().add(
                  SetRaffleLogo(logoContent, filename: filename),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.selectLogo),
          ),
        ],
      ),
    );
  }
}
