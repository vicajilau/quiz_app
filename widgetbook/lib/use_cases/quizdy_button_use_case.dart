// Copyright (C) 2026 Victor Carreras
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

import 'package:flutter/material.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Primary', type: QuizdyButton)
Widget buildPrimaryQuizdyButtonUseCase(BuildContext context) =>
    _ButtonTypeCard(type: QuizdyButtonType.primary);

@widgetbook.UseCase(name: 'Secondary', type: QuizdyButton)
Widget buildSecondaryQuizdyButtonUseCase(BuildContext context) =>
    _ButtonTypeCard(type: QuizdyButtonType.secondary);

@widgetbook.UseCase(name: 'Tertiary', type: QuizdyButton)
Widget buildTertiaryQuizdyButtonUseCase(BuildContext context) =>
    _ButtonTypeCard(type: QuizdyButtonType.tertiary);

@widgetbook.UseCase(name: 'Warning', type: QuizdyButton)
Widget buildWarningQuizdyButtonUseCase(BuildContext context) =>
    _ButtonTypeCard(type: QuizdyButtonType.warning);

@widgetbook.UseCase(name: 'Interactive', type: QuizdyButton)
Widget buildInteractiveQuizdyButtonUseCase(BuildContext context) {
  final type = context.knobs.object.dropdown<QuizdyButtonType>(
    label: 'Type',
    options: QuizdyButtonType.values,
    initialOption: QuizdyButtonType.primary,
    labelBuilder: (t) => t.name,
  );
  final title = context.knobs.string(label: 'Title', initialValue: 'Click me');
  final isLoading = context.knobs.boolean(
    label: 'Is loading',
    initialValue: false,
  );
  final disabled = context.knobs.boolean(
    label: 'Disabled',
    initialValue: false,
  );
  final expanded = context.knobs.boolean(
    label: 'Expanded',
    initialValue: false,
  );
  final showIcon = context.knobs.boolean(
    label: 'Show icon',
    initialValue: false,
  );

  return QuizdyButton(
    type: type,
    title: title,
    isLoading: isLoading,
    onPressed: disabled ? null : () {},
    expanded: expanded,
    icon: showIcon ? Icons.star_rounded : null,
  );
}

class _ButtonTypeCard extends StatelessWidget {
  final QuizdyButtonType type;

  const _ButtonTypeCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizdyButton(title: 'Idle', type: type, onPressed: () {}),
        const SizedBox(height: 8.0),
        QuizdyButton(
          title: 'Loading',
          type: type,
          onPressed: () {},
          isLoading: true,
        ),
        const SizedBox(height: 8.0),
        QuizdyButton(title: 'Disabled', type: type),
        const SizedBox(height: 8.0),
        QuizdyButton(
          title: 'Expanded',
          type: type,
          onPressed: () {},
          expanded: true,
        ),
      ],
    );
  }
}
