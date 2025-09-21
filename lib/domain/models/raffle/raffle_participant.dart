/// Represents a participant in a raffle.
class RaffleParticipant {
  /// The name of the participant.
  final String name;

  /// Whether this participant is still in the raffle (not yet selected).
  final bool isActive;

  /// Constructor for creating a `RaffleParticipant` instance.
  const RaffleParticipant({required this.name, this.isActive = true});

  /// Creates a copy of this participant with optional field overrides.
  RaffleParticipant copyWith({String? name, bool? isActive}) {
    return RaffleParticipant(
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Creates a `RaffleParticipant` from a plain string (name).
  factory RaffleParticipant.fromString(String name) {
    return RaffleParticipant(name: name.trim());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaffleParticipant &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RaffleParticipant(name: $name, isActive: $isActive)';
}
