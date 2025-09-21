import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/raffle/raffle_participant.dart';
import '../../../domain/models/raffle/raffle_session.dart';
import '../../../domain/models/raffle/raffle_winner.dart';
import 'raffle_event.dart';
import 'raffle_state.dart';

/// BLoC for managing raffle functionality.
class RaffleBloc extends Bloc<RaffleEvent, RaffleState> {
  final Random _random = Random();

  RaffleBloc() : super(RaffleInitial()) {
    on<UpdateParticipantText>(_onUpdateParticipantText);
    on<StartRaffleSelection>(_onStartRaffleSelection);
    on<CompleteRaffleSelection>(_onCompleteRaffleSelection);
    on<ConfirmWinner>(_onConfirmWinner);
    on<ResetRaffle>(_onResetRaffle);
    on<ClearParticipants>(_onClearParticipants);
    on<ClearWinners>(_onClearWinners);

    // Initialize with empty session
    add(UpdateParticipantText(''));
  }

  void _onUpdateParticipantText(
    UpdateParticipantText event,
    Emitter<RaffleState> emit,
  ) {
    try {
      // Parse the text into participants
      final lines = event.text.split('\n');
      final participants = <RaffleParticipant>[];

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isNotEmpty) {
          participants.add(RaffleParticipant.fromString(trimmedLine));
        }
      }

      // Get current session or create new one
      RaffleSession currentSession;
      if (state is RaffleLoaded) {
        currentSession = (state as RaffleLoaded).session;
      } else if (state is RaffleWinnerSelected) {
        currentSession = (state as RaffleWinnerSelected).session;
      } else {
        currentSession = RaffleSession.empty();
      }

      // Update participants while preserving winners and their inactive status
      final updatedParticipants = <RaffleParticipant>[];
      for (final participant in participants) {
        // Check if this participant is already a winner
        final isWinner = currentSession.winners.any(
          (winner) => winner.name == participant.name,
        );
        updatedParticipants.add(participant.copyWith(isActive: !isWinner));
      }

      final updatedSession = currentSession.copyWith(
        participants: updatedParticipants,
        participantText: event.text,
      );

      emit(RaffleLoaded(updatedSession));
    } catch (e) {
      emit(RaffleError('Error al procesar la lista de participantes: $e'));
    }
  }

  void _onStartRaffleSelection(
    StartRaffleSelection event,
    Emitter<RaffleState> emit,
  ) {
    if (state is RaffleLoaded) {
      final currentSession = (state as RaffleLoaded).session;

      if (currentSession.activeParticipants.isEmpty) {
        emit(RaffleError('No hay participantes activos para el sorteo'));
        return;
      }

      final updatedSession = currentSession.copyWith(isSelecting: true);
      emit(RaffleSelecting(updatedSession));
    }
  }

  void _onCompleteRaffleSelection(
    CompleteRaffleSelection event,
    Emitter<RaffleState> emit,
  ) {
    if (state is RaffleSelecting) {
      final currentSession = (state as RaffleSelecting).session;
      final updatedSession = currentSession.copyWith(isSelecting: false);
      emit(RaffleWinnerSelected(updatedSession, event.winnerName));
    }
  }

  void _onConfirmWinner(ConfirmWinner event, Emitter<RaffleState> emit) {
    RaffleSession currentSession;

    if (state is RaffleWinnerSelected) {
      currentSession = (state as RaffleWinnerSelected).session;
    } else if (state is RaffleLoaded) {
      currentSession = (state as RaffleLoaded).session;
    } else {
      emit(RaffleError('Estado inválido para confirmar ganador'));
      return;
    }

    try {
      // Add winner to winners list
      final newWinner = RaffleWinner(
        name: event.winnerName,
        position: currentSession.winners.length + 1,
        selectedAt: DateTime.now(),
      );

      // Update participants to mark the winner as inactive
      final updatedParticipants = currentSession.participants
          .map(
            (participant) => participant.name == event.winnerName
                ? participant.copyWith(isActive: false)
                : participant,
          )
          .toList();

      final updatedSession = currentSession.copyWith(
        participants: updatedParticipants,
        winners: [...currentSession.winners, newWinner],
        isSelecting: false,
      );

      emit(RaffleLoaded(updatedSession));
    } catch (e) {
      emit(RaffleError('Error al confirmar ganador: $e'));
    }
  }

  void _onResetRaffle(ResetRaffle event, Emitter<RaffleState> emit) {
    emit(RaffleLoaded(RaffleSession.empty()));
  }

  void _onClearParticipants(
    ClearParticipants event,
    Emitter<RaffleState> emit,
  ) {
    if (state is RaffleLoaded) {
      final currentSession = (state as RaffleLoaded).session;
      final updatedSession = currentSession.copyWith(
        participants: [],
        participantText: '',
      );
      emit(RaffleLoaded(updatedSession));
    }
  }

  void _onClearWinners(ClearWinners event, Emitter<RaffleState> emit) {
    if (state is RaffleLoaded) {
      final currentSession = (state as RaffleLoaded).session;

      // Reactivate all participants
      final reactivatedParticipants = currentSession.participants
          .map((participant) => participant.copyWith(isActive: true))
          .toList();

      final updatedSession = currentSession.copyWith(
        participants: reactivatedParticipants,
        winners: [],
      );
      emit(RaffleLoaded(updatedSession));
    }
  }

  /// Selects a random winner from active participants.
  String selectRandomWinner(List<RaffleParticipant> activeParticipants) {
    if (activeParticipants.isEmpty) {
      throw Exception('No hay participantes activos');
    }

    final randomIndex = _random.nextInt(activeParticipants.length);
    return activeParticipants[randomIndex].name;
  }
}
