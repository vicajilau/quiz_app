/// Represents a winner from a raffle session.
class RaffleWinner {
  /// The name of the winner.
  final String name;

  /// The position/order in which this person was selected (1st, 2nd, etc.).
  final int position;

  /// The timestamp when this person was selected.
  final DateTime selectedAt;

  /// Constructor for creating a `RaffleWinner` instance.
  const RaffleWinner({
    required this.name,
    required this.position,
    required this.selectedAt,
  });

  /// Creates a copy of this winner with optional field overrides.
  RaffleWinner copyWith({String? name, int? position, DateTime? selectedAt}) {
    return RaffleWinner(
      name: name ?? this.name,
      position: position ?? this.position,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaffleWinner &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          position == other.position;

  @override
  int get hashCode => name.hashCode ^ position.hashCode;

  @override
  String toString() =>
      'RaffleWinner(name: $name, position: $position, selectedAt: $selectedAt)';
}
