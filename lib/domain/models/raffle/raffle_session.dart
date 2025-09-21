import 'raffle_participant.dart';
import 'raffle_winner.dart';

/// Represents the current state of a raffle session.
class RaffleSession {
  /// List of all participants in the raffle.
  final List<RaffleParticipant> participants;

  /// List of winners selected so far.
  final List<RaffleWinner> winners;

  /// Whether the raffle is currently in progress (animating selection).
  final bool isSelecting;

  /// The raw text input from the user (for editing purposes).
  final String participantText;

  /// Constructor for creating a `RaffleSession` instance.
  const RaffleSession({
    required this.participants,
    required this.winners,
    this.isSelecting = false,
    this.participantText = '',
  });

  /// Creates an empty raffle session.
  factory RaffleSession.empty() {
    return const RaffleSession(
      participants: [],
      winners: [],
      isSelecting: false,
      participantText: '',
    );
  }

  /// Creates a copy of this session with optional field overrides.
  RaffleSession copyWith({
    List<RaffleParticipant>? participants,
    List<RaffleWinner>? winners,
    bool? isSelecting,
    String? participantText,
  }) {
    return RaffleSession(
      participants: participants ?? this.participants,
      winners: winners ?? this.winners,
      isSelecting: isSelecting ?? this.isSelecting,
      participantText: participantText ?? this.participantText,
    );
  }

  /// Gets only the active participants (those who haven't won yet).
  List<RaffleParticipant> get activeParticipants =>
      participants.where((p) => p.isActive).toList();

  /// Gets the total number of participants.
  int get totalParticipants => participants.length;

  /// Gets the number of active participants.
  int get activeParticipantsCount => activeParticipants.length;

  /// Gets the number of winners.
  int get winnersCount => winners.length;

  /// Whether there are active participants available for selection.
  bool get canSelectWinner => activeParticipants.isNotEmpty && !isSelecting;

  /// Whether the raffle has any participants.
  bool get hasParticipants => participants.isNotEmpty;

  /// Whether the raffle has any winners.
  bool get hasWinners => winners.isNotEmpty;

  @override
  String toString() =>
      'RaffleSession(participants: ${participants.length}, winners: ${winners.length}, isSelecting: $isSelecting)';
}
