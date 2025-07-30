import '../../../core/deep_collection_equality.dart';
import '../../../core/deep_copy_mixin.dart';
import 'burst.dart';

/// Represents a thread containing a list of bursts (tasks) that a process executes.
/// Each thread has an identifier, a list of bursts, and an enabled status.
class Thread with DeepCopy<Thread> {
  /// Unique identifier for the thread.
  final String id;

  /// List of bursts associated with this thread.
  final List<Burst> bursts;

  /// Indicates whether the thread is active and enabled.
  bool enabled;

  /// Constructor for the Thread class.
  ///
  /// [id] is the unique identifier of the thread.
  /// [bursts] is the list of bursts associated with the thread.
  /// [enabled] specifies if the thread is active (default is true).
  Thread({
    required this.id,
    required this.bursts,
    this.enabled = true,
  });

  /// Calculates the total duration of all bursts in this thread.
  ///
  /// Returns the total time (sum of durations of all bursts).
  int get totalDuration {
    return bursts.fold(0, (total, burst) => total + burst.duration);
  }

  /// Converts the Thread object into a JSON-serializable map.
  ///
  /// Returns a `Map<String, dynamic>` representing the thread in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enabled': enabled,
      'bursts': bursts.map((burst) => burst.toJson()).toList(),
    };
  }

  /// Creates a Thread instance from a JSON map.
  ///
  /// [json] is the JSON map containing the thread data.
  /// Returns a `Thread` object.
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      enabled: json['enabled'] ?? true,
      bursts: (json['bursts'] as List<dynamic>)
          .map((burstJson) => Burst.fromJson(burstJson))
          .toList(),
    );
  }

  @override
  Thread copy() {
    return Thread(
        id: id,
        bursts: bursts.map((burst) => burst.copy()).toList(),
        enabled: enabled);
  }

  /// Overrides the equality operator to compare `Thread` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Thread &&
        other.id == id &&
        other.enabled == enabled &&
        DeepCollectionEquality.listEquals(other.bursts, bursts);
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      id.hashCode ^ enabled.hashCode ^ bursts.hashCode ^ enabled.hashCode;

  @override
  String toString() => "Thread: {id: $id, enabled: $enabled, bursts: $bursts}";
}
