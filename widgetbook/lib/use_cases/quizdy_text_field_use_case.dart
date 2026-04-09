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
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyTextField)
Widget buildQuizdyTextFieldUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _TextFieldCard(
          title: 'Default',
          child: QuizdyTextField(
            controller: TextEditingController(text: 'Quiz about history'),
            hint: 'Type a prompt',
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'Hint',
          child: QuizdyTextField(
            controller: TextEditingController(),
            hint: 'Type a prompt',
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'Error',
          child: QuizdyTextField(
            controller: TextEditingController(text: 'Invalid value'),
            hint: 'Type a prompt',
            errorText: 'Please enter a valid value',
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'Read only',
          child: QuizdyTextField(
            controller: TextEditingController(text: 'Read-only content'),
            hint: 'Type a prompt',
            readOnly: true,
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'Obscured (password)',
          child: QuizdyTextField(
            controller: TextEditingController(text: 'mysecretpassword'),
            hint: 'Password',
            obscureText: true,
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'With prefix & suffix icons',
          child: QuizdyTextField(
            controller: TextEditingController(text: '42'),
            hint: 'Amount',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.clear),
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'With suffix text',
          child: QuizdyTextField(
            controller: TextEditingController(text: '100'),
            hint: 'Duration',
            suffixText: 'min',
          ),
        ),
        const SizedBox(height: 10.0),
        _TextFieldCard(
          title: 'Multiline',
          child: QuizdyTextField(
            controller: TextEditingController(
              text: 'This is a multiline text field.\nIt supports multiple lines.',
            ),
            hint: 'Type a description',
            minLines: 3,
            maxLines: 5,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyTextField)
Widget buildInteractiveQuizdyTextFieldUseCase(BuildContext context) {
  final hint = context.knobs.string(label: 'Hint', initialValue: 'Type something...');
  final errorText = context.knobs.stringOrNull(label: 'Error text', initialValue: null);
  final readOnly = context.knobs.boolean(label: 'Read only', initialValue: false);
  final obscureText = context.knobs.boolean(label: 'Obscure text', initialValue: false);
  final suffixText = context.knobs.stringOrNull(label: 'Suffix text', initialValue: null);
  final minLines = context.knobs.int.slider(
    label: 'Min lines',
    initialValue: 1,
    min: 1,
    max: 6,
  );
  final maxLines = context.knobs.int.slider(
    label: 'Max lines',
    initialValue: 1,
    min: 1,
    max: 8,
  );

  return _InteractiveTextField(
    hint: hint,
    errorText: errorText,
    readOnly: readOnly,
    obscureText: obscureText,
    suffixText: suffixText,
    minLines: minLines,
    maxLines: maxLines,
  );
}

class _InteractiveTextField extends StatefulWidget {
  final String hint;
  final String? errorText;
  final bool readOnly;
  final bool obscureText;
  final String? suffixText;
  final int minLines;
  final int maxLines;

  const _InteractiveTextField({
    required this.hint,
    this.errorText,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  State<_InteractiveTextField> createState() => _InteractiveTextFieldState();
}

class _InteractiveTextFieldState extends State<_InteractiveTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuizdyTextField(
      controller: _controller,
      hint: widget.hint,
      errorText: widget.errorText,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      suffixText: widget.suffixText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
    );
  }
}

class _TextFieldCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _TextFieldCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
