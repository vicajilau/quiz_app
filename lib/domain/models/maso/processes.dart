import 'package:quiz_app/domain/models/maso/process_mode.dart';
import 'package:quiz_app/domain/models/maso/regular_process.dart';

import '../../../core/deep_collection_equality.dart';
import 'burst_process.dart';
import 'i_process.dart';

/// The Metadata class represents the metadata of a MASO file, including its name, version, and description.
class Processes {
  /// The name of the MASO file
  ProcessesMode mode;

  /// The version of the MASO file
  final List<IProcess> elements;

  /// Constructor for creating a Metadata instance with name, version, and description.
  Processes({required this.mode, required this.elements});

  /// Factory constructor to create a Metadata instance from a JSON map.
  factory Processes.fromJson(Map<String, dynamic> json) {
    final mode = ProcessesMode.fromJson(json['mode'] as String);

    final List<IProcess> elements = (json['elements'] as List<dynamic>)
        .map<IProcess>((e) {
          final data = e as Map<String, dynamic>;
          switch (mode) {
            case ProcessesMode.regular:
              return RegularProcess.fromJson(data);
            case ProcessesMode.burst:
              return BurstProcess.fromJson(data);
          }
        })
        .toList();

    return Processes(mode: mode, elements: elements);
  }

  /// Converts the Metadata instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'mode': mode.toString(), // Convert the 'mode' field to JSON
    'elements': elements
        .map((e) => e.toJson())
        .toList(), // Convert the 'elements' field to JSON
  };

  /// Override the equality operator to compare Metadata instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Processes &&
        other.mode == mode &&
        DeepCollectionEquality.listEquals(other.elements, elements);
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode => mode.hashCode ^ elements.hashCode;

  Processes copyWith({ProcessesMode? mode, List<IProcess>? elements}) {
    return Processes(
      mode: mode ?? this.mode,
      elements:
          elements ?? this.elements.map((element) => element.copy()).toList(),
    );
  }

  @override
  String toString() => "Processes {mode: $mode, elements: $elements}";
}
