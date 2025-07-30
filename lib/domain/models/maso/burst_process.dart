import 'package:quiz_app/core/deep_collection_equality.dart';
import 'package:quiz_app/domain/models/maso/thread.dart';

import 'i_process.dart';

/// The `BurstProcess` class extends the `IProcess` interface,
/// representing a process with a list of CPU burst durations.
/// This class includes several attributes such as `name`,
/// `arrivalTime`, `cpuBurstDuration`, `enabled`, and `ioDevice`
/// to describe the process and its behavior during execution.
class BurstProcess extends IProcess {
  final List<Thread> threads;

  /// Constructor to initialize the attributes of the BurstProcess.
  BurstProcess({
    required super.id,
    required super.arrivalTime,
    required this.threads,
    required super.enabled,
  });

  /// Factory method that creates a BurstProcess instance from a JSON map.
  /// This is useful for deserialization when data is read from JSON format.
  factory BurstProcess.fromJson(Map<String, dynamic> json) {
    return BurstProcess(
      id: json['id'],
      arrivalTime: json['arrival_time'],
      threads: (json['threads'] as List)
          .map((thread) => Thread.fromJson(thread))
          .toList(),
      enabled: json['enabled'],
    );
  }

  /// Overrides the toJson method to return a map representation of the
  /// BurstProcess object. This allows serialization of the object.
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'arrival_time': arrivalTime,
    'enabled': enabled,
    'threads': threads.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() =>
      "Burst Process: {id: $id, arrivalTime: $arrivalTime, enabled: $enabled, threads: $threads}";

  /// Overrides the equality operator to compare `Process` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BurstProcess &&
        other.id == id &&
        other.arrivalTime == arrivalTime &&
        DeepCollectionEquality.listEquals(other.threads, threads) &&
        other.enabled == enabled;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      id.hashCode ^ arrivalTime.hashCode ^ threads.hashCode ^ enabled.hashCode;

  @override
  BurstProcess copy() {
    return BurstProcess(
      id: id,
      arrivalTime: arrivalTime,
      threads: threads.map((thread) => thread.copy()).toList(),
      enabled: enabled,
    );
  }
}
