import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../../blocs/raffle_bloc/raffle_event.dart';

/// Shows a confirmation dialog to clear all winners from the raffle.
///
/// Returns a [Future<bool>] that completes with:
/// - `true` if the user confirmed and winners were cleared
/// - `false` if the user canceled the operation
Future<bool> showClearWinnersDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.resetWinnersConfirmTitle),
      content: Text(AppLocalizations.of(context)!.resetWinnersConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(AppLocalizations.of(context)!.reset),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    context.read<RaffleBloc>().add(ClearWinners());
    return true;
  }

  return false;
}
