import 'package:quiz_app/domain/models/raffle/raffle_session.dart';

/// Abstract class representing the base state for raffle operations.
abstract class RaffleState {}

/// The initial state of the raffle.
class RaffleInitial extends RaffleState {}

/// State representing the current raffle session.
class RaffleLoaded extends RaffleState {
  final RaffleSession session;

  RaffleLoaded(this.session);
}

/// State representing that the raffle selection animation is in progress.
class RaffleSelecting extends RaffleState {
  final RaffleSession session;

  RaffleSelecting(this.session);
}

/// State representing that a winner has been selected.
class RaffleWinnerSelected extends RaffleState {
  final RaffleSession session;
  final String selectedWinner;

  RaffleWinnerSelected(this.session, this.selectedWinner);
}

/// State representing an error in the raffle process.
class RaffleError extends RaffleState {
  final String message;

  RaffleError(this.message);
}

/// State representing a warning message that should be shown to the user.
class RaffleWarning extends RaffleState {
  final RaffleSession session;
  final String message;

  RaffleWarning(this.session, this.message);
}
