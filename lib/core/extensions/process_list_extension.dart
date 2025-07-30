import 'package:quiz_app/domain/models/maso/burst_process.dart';
import 'package:quiz_app/domain/models/maso/i_process.dart';
import 'package:quiz_app/domain/models/maso/process_mode.dart';
import 'package:quiz_app/domain/models/maso/regular_process.dart';

extension ProcessListExtension on List<IProcess> {
  /// Returns the mode of the process list based on its content.
  /// Throws an error if the list is empty or contains unknown types.
  ProcessesMode getMode() {
    if (isEmpty) {
      throw StateError('Process list is empty');
    }

    final first = this.first;

    if (first is RegularProcess) {
      return ProcessesMode.regular;
    } else if (first is BurstProcess) {
      return ProcessesMode.burst;
    } else {
      throw UnimplementedError(
        'Unrecognized process type: ${first.runtimeType}',
      );
    }
  }

  /// Checks if a process with the specified [name] exists in the list,
  /// optionally ignoring the process at the given [position].
  ///
  /// - [name]: The name of the process to search for (case-insensitive).
  /// - [position]: (Optional) The index of the process to exclude from the search.
  ///
  /// Returns `true` if a matching process exists, `false` otherwise.
  bool containProcessWithName(String name, {int? position}) {
    /// Create a filtered list excluding the element at the given [position], if valid.
    final filteredList = position != null && position >= 0 && position < length
        ? asMap().entries
              .where(
                (entry) => entry.key != position,
              ) // Exclude the specified index.
              .map((entry) => entry.value) // Extract the process values.
              .toList() // Convert back to a list.
        : this; // Use the original list if [position] is invalid or not provided.

    /// Check if any process in the filtered list matches the [name].
    return filteredList.any(
      (x) => x.id.toLowerCase().trim() == name.toLowerCase().trim(),
    );
  }
}
