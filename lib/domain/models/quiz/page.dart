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

import 'package:flutter/foundation.dart';
import 'package:quizdy/domain/models/quiz/ui_element.dart';

/// Represents a single page or view within a study sequence, containing multiple UI elements.
class Page {
  /// The collection of elements that make up the page's layout.
  final List<UiElement> uiElements;

  /// Constructor for a `Page`.
  const Page({required this.uiElements});

  /// Creates a `Page` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the page data.
  /// - Returns: A populated `Page` instance.
  factory Page.fromJson(Map<String, dynamic> json) {
    // Check both components (issue #221) and ui_elements (legacy)
    final elementsJson =
        (json['components'] ?? json['ui_elements']) as List<dynamic>? ?? [];
    final uiElements = elementsJson
        .map(
          (elementJson) =>
              UiElement.fromJson(elementJson as Map<String, dynamic>),
        )
        .toList();

    return Page(uiElements: uiElements);
  }

  /// Converts the `Page` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation.
  Map<String, dynamic> toJson() {
    return {
      'components': uiElements.map((element) => element.toJson()).toList(),
    };
  }

  /// Creates a deep copy of the `Page` with optional parameter modifications.
  Page copyWith({List<UiElement>? uiElements}) {
    return Page(
      uiElements:
          uiElements ?? this.uiElements.map((e) => e.copyWith()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Page && listEquals(other.uiElements, uiElements);
  }

  @override
  int get hashCode => Object.hashAll(uiElements);

  @override
  String toString() => 'Page(uiElements: ${uiElements.length})';
}
