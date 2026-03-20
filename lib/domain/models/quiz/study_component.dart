// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Represents a dynamic UI component within a quiz page, defined by a type and associated properties.
/// This flexible structure allows for generative UI definitions based on a `componentType` and arbitrary `props
enum StudyComponentType {
  sectionTitle,
  paragraph,
  keyDefinition,
  numberedList,
  comparisonTable,
  quote,
  warning,
  formula,
  timeline,
  prosCons,
  keyConcepts,
  reminder,
  iconCards,
}

/// Represents a UI component element within a slide.
///
/// This flexible structure allows for generative UI definitions based on
/// a `componentType` and arbitrary `props`.
class StudyComponent {
  /// The type of the UI component to render (e.g., 'ConceptHighlight').
  final StudyComponentType componentType;

  /// The dynamic properties or data for the component.
  final Map<String, dynamic> props;

  /// Constructor for a `StudyComponent`.
  const StudyComponent({required this.componentType, required this.props});

  /// Creates a `StudyComponent` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the dynamic layout data.
  /// - Returns: A populated `StudyComponent` instance.
  factory StudyComponent.fromJson(Map<String, dynamic> json) {
    // Determine the type: check both the new issue #221 'type' and legacy 'component_type'.
    // Normalise snake_case → camelCase so values like "section_title" match enum
    // names like "sectionTitle".
    String toCamelCase(String s) => s.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (m) => m.group(1)!.toUpperCase(),
    );

    final rawType =
        (json['type'] as String?)?.trim() ??
        (json['component_type'] as String?)?.trim();
    final normalised = rawType != null ? toCamelCase(rawType) : null;

    final type = StudyComponentType.values.firstWhereOrNull(
      (e) => e.name == normalised,
    );

    // Collect all properties dynamically.
    // In legacy format, properties were inside 'props'.
    // In the new format (issue #221), properties like 'title', 'subtitle', 'body' are placed at the root level of the component object.
    Map<String, dynamic> extractedProps = {};
    if (json.containsKey('props')) {
      extractedProps = Map<String, dynamic>.from(json['props']);
    }

    // Extract all other keys (excluding 'type' and 'props') into props
    json.forEach((key, value) {
      if (key != 'type' && key != 'component_type' && key != 'props') {
        extractedProps[key] = value;
      }
    });

    return StudyComponent(
      componentType: type ?? StudyComponentType.sectionTitle,
      props: extractedProps,
    );
  }

  /// Converts the `StudyComponent` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation.
  Map<String, dynamic> toJson() {
    // When serializing, we output the new format.
    final json = <String, dynamic>{'type': componentType};
    json.addAll(props);
    return json;
  }

  /// Creates a copy of the `StudyComponent` with optional parameter modifications.
  StudyComponent copyWith({
    StudyComponentType? componentType,
    Map<String, dynamic>? props,
  }) {
    return StudyComponent(
      componentType: componentType ?? this.componentType,
      props: props ?? Map<String, dynamic>.from(this.props),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudyComponent &&
        other.componentType == componentType &&
        mapEquals(other.props, props);
  }

  @override
  int get hashCode =>
      componentType.hashCode ^
      Object.hashAll(props.keys) ^
      Object.hashAll(props.values);

  @override
  String toString() =>
      'StudyComponent(componentType: $componentType, props: $props)';
}
