import 'i_process.dart';

/// The `RegularProcess` class implements the `IProcess` interface,
/// representing a regular process in a scheduling system.
/// This class includes several attributes such as `name`,
/// `arrivalTime`, `serviceTime` and `enabled` to
/// describe the process and its characteristics.
class RegularProcess extends IProcess {
  int serviceTime;
  int priority;

  /// Constructor to initialize the attributes of the RegularProcess.
  RegularProcess({
    required super.id,
    required super.arrivalTime,
    required this.serviceTime,
    required super.enabled,
    this.priority = 0,
  });

  /// Factory method that creates a RegularProcess instance from a JSON map.
  /// This is useful for deserialization when data is read from JSON format.
  factory RegularProcess.fromJson(Map<String, dynamic> json) {
    return RegularProcess(
      id: json['id'],
      arrivalTime: json['arrival_time'],
      serviceTime: json['service_time'],
      enabled: json['enabled'],
      priority: json['priority'] ?? 0,
    );
  }

  /// Overrides the toJson method to return a map representation of the
  /// RegularProcess object. This allows serialization of the object.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'arrival_time': arrivalTime,
        'service_time': serviceTime,
        'enabled': enabled,
        'priority': priority,
      };

  @override
  String toString() =>
      "Regular Process: {id: $id, arrivalTime: $arrivalTime, serviceTime: $serviceTime, enabled: $enabled}";

  /// Overrides the equality operator to compare `RegularProcess` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegularProcess &&
        other.id == id &&
        other.arrivalTime == arrivalTime &&
        other.serviceTime == serviceTime &&
        other.enabled == enabled &&
        other.priority == priority;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      id.hashCode ^
      arrivalTime.hashCode ^
      serviceTime.hashCode ^
      enabled.hashCode ^
      priority.hashCode;

  @override
  RegularProcess copy() {
    return RegularProcess(
        id: id,
        arrivalTime: arrivalTime,
        serviceTime: serviceTime,
        enabled: enabled,
        priority: priority);
  }
}
