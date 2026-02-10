import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/logo_widget.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/custom_colors.dart';
import 'package:quiz_app/domain/models/raffle/raffle_logo.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_event.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_state.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/raffle_narrow_layout.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/raffle_wide_layout.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/winner_dialog.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/reset_raffle_dialog.dart';
import 'package:quiz_app/routes/app_router.dart';

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
              onPressed: () => context.go(AppRoutes.home),
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
                        ? () => context.go(AppRoutes.raffleWinners)
                        : null,
                    icon: Icon(
                      Icons.emoji_events,
                      color: hasWinners
                          ? Theme.of(context).extension<CustomColors>()!.warning
                          : AppTheme.zinc500,
                    ),
                    tooltip: AppLocalizations.of(context)!.viewWinners,
                  );
                },
              ),
              // Reset raffle button
              IconButton(
                onPressed: () => showResetRaffleDialog(context),
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
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              } else if (state is RaffleWarning) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(
                      context,
                    ).extension<CustomColors>()!.onWarningContainer,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.okButton,
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
                  return const RaffleWideLayout();
                } else {
                  return const RaffleNarrowLayout();
                }
              },
            ),
          ),
        );
      },
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
          context.go(AppRoutes.raffleWinners);
        },
      ),
    );
  }

  void _showLogoSelector(BuildContext context) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Design Tokens (matching SubmitQuizDialog)
        final dialogBg = isDark ? AppTheme.cardColorDark : Colors.white;
        final titleColor = isDark ? Colors.white : Colors.black;
        final contentColor = isDark
            ? AppTheme.zinc400
            : AppTheme.textSecondaryColor;
        final closeBtnBg = isDark
            ? AppTheme.borderColorDark
            : AppTheme.cardColorLight;
        final closeBtnIcon = isDark
            ? AppTheme.zinc400
            : AppTheme.textSecondaryColor;

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
                // Header (Title + Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectLogo,
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

                // Content
                if (hasLogo) ...[
                  // Logo Preview
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : AppTheme.zinc100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppTheme.zinc300,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: LogoWidget(
                        logo: currentLogo!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image,
                              color: AppTheme.zinc500,
                              size: 40,
                            ),
                        loadingBuilder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.logoPreview,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: contentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  AppLocalizations.of(context)!.logoUrlHint,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: contentColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Column(
                  children: [
                    // Select Logo Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();

                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'png',
                              'jpg',
                              'jpeg',
                              'gif',
                              'webp',
                              'svg',
                            ],
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.selectLogo,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    if (hasLogo) ...[
                      const SizedBox(height: 12),
                      // Remove Logo Button (Secondary Destructive)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<RaffleBloc>().add(RemoveRaffleLogo());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.removeLogo,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
