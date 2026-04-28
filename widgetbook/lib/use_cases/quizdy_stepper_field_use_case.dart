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
import 'package:flutter/services.dart';
import 'package:quizdy/presentation/widgets/quizdy_stepper_field.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyStepperField)
Widget buildQuizdyStepperFieldUseCase(BuildContext context) {
  return const SingleChildScrollView(
    child: Column(
      children: [
        _StepperCard(title: 'Default', initialValue: 10),
        SizedBox(height: 10.0),
        _StepperCard(title: 'Min boundary (1)', initialValue: 1),
        SizedBox(height: 10.0),
        _StepperCard(title: 'Large value', initialValue: 100),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyStepperField)
Widget buildInteractiveQuizdyStepperFieldUseCase(BuildContext context) {
  final initialValue = context.knobs.int.slider(
    label: 'Initial value',
    initialValue: 10,
    min: 1,
    max: 100,
  );

  return _InteractiveStepperField(initialValue: initialValue);
}

class _InteractiveStepperField extends StatefulWidget {
  final int initialValue;

  const _InteractiveStepperField({required this.initialValue});

  @override
  State<_InteractiveStepperField> createState() =>
      _InteractiveStepperFieldState();
}

class _InteractiveStepperFieldState extends State<_InteractiveStepperField> {
  late final TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: '$_value');
  }

  @override
  void didUpdateWidget(_InteractiveStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _controller.text = '$_value';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() => setState(() {
    _value++;
    _controller.text = '$_value';
  });

  void _decrement() => setState(() {
    if (_value > 1) {
      _value--;
      _controller.text = '$_value';
    }
  });

  @override
  Widget build(BuildContext context) {
    return QuizdyStepperField(
      controller: _controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) setState(() => _value = parsed);
      },
      onIncrement: _increment,
      onDecrement: _decrement,
    );
  }
}

class _StepperCard extends StatefulWidget {
  final String title;
  final int initialValue;

  const _StepperCard({required this.title, required this.initialValue});

  @override
  State<_StepperCard> createState() => _StepperCardState();
}

class _StepperCardState extends State<_StepperCard> {
  late final TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: '$_value');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() => setState(() {
    _value++;
    _controller.text = '$_value';
  });

  void _decrement() => setState(() {
    if (_value > 1) {
      _value--;
      _controller.text = '$_value';
    }
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12.0),
            QuizdyStepperField(
              controller: _controller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null) setState(() => _value = parsed);
              },
              onIncrement: _increment,
              onDecrement: _decrement,
            ),
          ],
        ),
      ),
    );
  }
}
