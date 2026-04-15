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
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdySwitch)
Widget buildQuizdySwitchUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _SwitchCard(
          title: 'On (enabled)',
          child: QuizdySwitch(value: true, onChanged: (_) {}),
        ),
        const SizedBox(height: 10.0),
        _SwitchCard(
          title: 'Off (enabled)',
          child: QuizdySwitch(value: false, onChanged: (_) {}),
        ),
        const SizedBox(height: 10.0),
        const _SwitchCard(
          title: 'On (disabled)',
          child: QuizdySwitch(value: true, onChanged: null),
        ),
        const SizedBox(height: 10.0),
        const _SwitchCard(
          title: 'Off (disabled)',
          child: QuizdySwitch(value: false, onChanged: null),
        ),
        const SizedBox(height: 10.0),
        _SwitchCard(
          title: 'Custom color (teal)',
          child: QuizdySwitch(
            value: true,
            onChanged: (_) {},
            activeTrackColor: AppTheme.secondaryColor,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdySwitch)
Widget buildInteractiveQuizdySwitchUseCase(BuildContext context) {
  final initialValue = context.knobs.boolean(label: 'Initial value', initialValue: false);
  final disabled = context.knobs.boolean(label: 'Disabled', initialValue: false);
  final useCustomColor = context.knobs.boolean(
    label: 'Custom track color',
    initialValue: false,
  );
  final activeTrackColor = context.knobs.object.dropdown<Color>(
    label: 'Track color',
    options: [AppTheme.secondaryColor, AppTheme.errorColor],
    initialOption: AppTheme.secondaryColor,
    labelBuilder: (c) => c == AppTheme.secondaryColor ? 'Secondary' : 'Error',
  );

  return _InteractiveSwitch(
    initialValue: initialValue,
    disabled: disabled,
    activeTrackColor: useCustomColor ? activeTrackColor : null,
  );
}

class _InteractiveSwitch extends StatefulWidget {
  final bool initialValue;
  final bool disabled;
  final Color? activeTrackColor;

  const _InteractiveSwitch({
    required this.initialValue,
    required this.disabled,
    this.activeTrackColor,
  });

  @override
  State<_InteractiveSwitch> createState() => _InteractiveSwitchState();
}

class _InteractiveSwitchState extends State<_InteractiveSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(_InteractiveSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuizdySwitch(
      value: _value,
      onChanged: widget.disabled ? null : (v) => setState(() => _value = v),
      activeTrackColor: widget.activeTrackColor,
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SwitchCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            child,
          ],
        ),
      ),
    );
  }
}
