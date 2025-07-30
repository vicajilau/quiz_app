import 'package:quiz_app/core/deep_copy_mixin.dart';
import 'package:quiz_app/domain/models/maso/burst_type.dart';

/// Represents a burst, which can either be a CPU task or an I/O operation.
/// Each burst has a type (e.g., 'cpu', 'io') and a duration in time units.
class Burst with DeepCopy<Burst> {
  /// The type of burst, either 'cpu' or 'io'.
  BurstType type;

  /// Duration of the burst in time units.
  int duration;

  /// Constructor for the Burst class.
  ///
  /// [type] specifies the type of the burst ('cpu' or 'io').
  /// [duration] indicates the time duration of the burst.
  Burst({required this.type, required this.duration});

  /// Converts the Burst object into a JSON-serializable map.
  ///
  /// Returns a `Map<String, dynamic>` representing the burst in JSON format.
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'duration': duration};
  }

  /// Creates a Burst instance from a JSON map.
  ///
  /// [json] is the JSON map containing the burst data.
  /// Returns a `Burst` object.
  factory Burst.fromJson(Map<String, dynamic> json) {
    return Burst(
      type: BurstType.fromJson(json['type'] as String),
      duration: json['duration'],
    );
  }

  @override
  Burst copy() {
    return Burst(type: type, duration: duration);
  }

  /// Overrides the equality operator to compare `Burst` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Burst && other.type == type && other.duration == duration;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode => type.hashCode ^ duration.hashCode;

  @override
  String toString() => "Burst: {type: $type, duration: $duration}";
}
