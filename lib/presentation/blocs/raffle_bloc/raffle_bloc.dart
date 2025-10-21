import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/raffle_storage_service.dart';
import '../../../domain/models/raffle/raffle_logo.dart';
import '../../../domain/models/raffle/raffle_participant.dart';
import '../../../domain/models/raffle/raffle_session.dart';
import '../../../domain/models/raffle/raffle_winner.dart';
import 'raffle_event.dart';
import 'raffle_state.dart';

/// BLoC for managing raffle functionality.
class RaffleBloc extends Bloc<RaffleEvent, RaffleState> {
  final Random _random = Random();
  final RaffleStorageService _storageService = RaffleStorageService.instance;

  RaffleBloc() : super(RaffleInitial()) {
    on<UpdateParticipantText>(_onUpdateParticipantText);
    on<StartRaffleSelection>(_onStartRaffleSelection);
    on<CompleteRaffleSelection>(_onCompleteRaffleSelection);
    on<ConfirmWinner>(_onConfirmWinner);
    on<ResetRaffle>(_onResetRaffle);
    on<ClearParticipants>(_onClearParticipants);
    on<ClearWinners>(_onClearWinners);
    on<SetRaffleLogo>(_onSetRaffleLogo);
    on<RemoveRaffleLogo>(_onRemoveRaffleLogo);
    on<LoadPersistedLogo>(_onLoadPersistedLogo);
    on<ShowWarning>(_onShowWarning);
    on<DismissWarning>(_onDismissWarning);

    // Initialize with loading persisted logo first
    add(LoadPersistedLogo());
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
    final currentState = state;
    if (currentState is RaffleLoaded) {
      // Preserve only the logo when resetting (clear everything else including participantText)
      final logo = currentState.session.logo;
      emit(RaffleLoaded(RaffleSession.empty().copyWith(logo: logo)));
    } else {
      emit(RaffleLoaded(RaffleSession.empty()));
    }
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
        participantText: currentSession.participantText, // Preserve the text
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

  void _onSetRaffleLogo(SetRaffleLogo event, Emitter<RaffleState> emit) async {
    final currentState = state;
    if (currentState is RaffleLoaded) {
      // Create RaffleLogo from the provided bytes
      final logo = RaffleLogo.fromFile(event.logoBytes, event.filename);

      // Always update the UI first, regardless of persistence success
      final updatedSession = currentState.session.copyWith(logo: logo);
      emit(RaffleLoaded(updatedSession));

      // Try to save logo to persistent storage
      final saved = await _storageService.saveLogo(logo);
      if (!saved) {
        // If saving fails (e.g., image too large), show a warning
        // but keep the logo in memory for the current session
        emit(
          RaffleWarning(
            updatedSession,
            'La imagen es demasiado grande para guardarse. Se usará solo durante esta sesión.',
          ),
        );
      }
    }
  }

  void _onRemoveRaffleLogo(
    RemoveRaffleLogo event,
    Emitter<RaffleState> emit,
  ) async {
    final currentState = state;
    if (currentState is RaffleLoaded) {
      // Remove logo from persistent storage
      await _storageService.removeLogo();

      final updatedSession = currentState.session.copyWithoutLogo();
      emit(RaffleLoaded(updatedSession));
    }
  }

  void _onLoadPersistedLogo(
    LoadPersistedLogo event,
    Emitter<RaffleState> emit,
  ) async {
    try {
      final persistedLogo = await _storageService.getLogo();

      if (persistedLogo != null) {
        final currentState = state;
        if (currentState is RaffleLoaded) {
          final updatedSession = currentState.session.copyWith(
            logo: persistedLogo,
          );
          emit(RaffleLoaded(updatedSession));
        } else {
          // If no current session exists, create one with the persisted logo
          final session = RaffleSession.empty().copyWith(logo: persistedLogo);
          emit(RaffleLoaded(session));
        }
      } else {
        // If no persisted logo, just create empty session if not exists
        if (state is! RaffleLoaded && state is! RaffleWinnerSelected) {
          emit(RaffleLoaded(RaffleSession.empty()));
        }
      }

      // Initialize with empty participant text after loading logo
      add(UpdateParticipantText(''));
    } catch (e) {
      // If loading fails, just continue with empty session
      if (state is! RaffleLoaded && state is! RaffleWinnerSelected) {
        emit(RaffleLoaded(RaffleSession.empty()));
      }
      add(UpdateParticipantText(''));
    }
  }

  void _onShowWarning(ShowWarning event, Emitter<RaffleState> emit) {
    final currentState = state;
    if (currentState is RaffleLoaded) {
      emit(RaffleWarning(currentState.session, event.message));
    }
  }

  void _onDismissWarning(DismissWarning event, Emitter<RaffleState> emit) {
    final currentState = state;
    if (currentState is RaffleWarning) {
      emit(RaffleLoaded(currentState.session));
    }
  }
}
