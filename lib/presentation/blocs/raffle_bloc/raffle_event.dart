/// Abstract class representing the base event for raffle operations.
abstract class RaffleEvent {}

/// Event to update the participant list from text input.
class UpdateParticipantText extends RaffleEvent {
  final String text;
  UpdateParticipantText(this.text);
}

/// Event to start the raffle selection process.
class StartRaffleSelection extends RaffleEvent {}

/// Event to complete the raffle selection with a winner.
class CompleteRaffleSelection extends RaffleEvent {
  final String winnerName;
  CompleteRaffleSelection(this.winnerName);
}

/// Event to remove a winner from the participants and add to winners list.
class ConfirmWinner extends RaffleEvent {
  final String winnerName;
  ConfirmWinner(this.winnerName);
}

/// Event to reset the entire raffle session.
class ResetRaffle extends RaffleEvent {}

/// Event to clear all participants.
class ClearParticipants extends RaffleEvent {}

/// Event to clear all winners.
class ClearWinners extends RaffleEvent {}

/// Event to set a custom logo for the raffle.
class SetRaffleLogo extends RaffleEvent {
  final String logoUrl;
  SetRaffleLogo(this.logoUrl);
}

/// Event to remove the custom logo from the raffle.
class RemoveRaffleLogo extends RaffleEvent {}
