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
import 'package:quizdy/presentation/widgets/quizdy_selectable_card.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdySelectableCard)
Widget buildQuizdySelectableCardUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _SelectableCardSection(
          title: 'Unselected',
          child: QuizdySelectableCard(
            icon: Icons.quiz_outlined,
            title: 'Multiple choice',
            description: 'One correct answer per question',
            isSelected: false,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10.0),
        _SelectableCardSection(
          title: 'Selected',
          child: QuizdySelectableCard(
            icon: Icons.quiz_outlined,
            title: 'Multiple choice',
            description: 'One correct answer per question',
            isSelected: true,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10.0),
        _SelectableCardSection(
          title: 'Locked',
          child: QuizdySelectableCard(
            icon: Icons.workspace_premium_outlined,
            title: 'True / False',
            description: 'Upgrade to unlock this mode',
            isSelected: false,
            isLocked: true,
          ),
        ),
        const SizedBox(height: 10.0),
        _SelectableCardSection(
          title: 'Selected with bottom content',
          child: QuizdySelectableCard(
            icon: Icons.layers_outlined,
            title: 'Flashcards',
            description: 'Review cards with flip animations',
            isSelected: true,
            onTap: () {},
            bottomContent: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '20 cards ready to review',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdySelectableCard)
Widget buildInteractiveQuizdySelectableCardUseCase(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Multiple choice');
  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'One correct answer per question',
  );
  final isLocked = context.knobs.boolean(label: 'Locked', initialValue: false);
  final hasBottomContent = context.knobs.boolean(
    label: 'Show bottom content',
    initialValue: false,
  );
  final icon = context.knobs.object.dropdown<IconData>(
    label: 'Icon',
    options: [
      Icons.quiz_outlined,
      Icons.layers_outlined,
      Icons.workspace_premium_outlined,
      Icons.school_outlined,
      Icons.star_outline,
    ],
    initialOption: Icons.quiz_outlined,
    labelBuilder: (i) {
      if (i == Icons.quiz_outlined) return 'Quiz';
      if (i == Icons.layers_outlined) return 'Layers';
      if (i == Icons.workspace_premium_outlined) return 'Premium';
      if (i == Icons.school_outlined) return 'School';
      return 'Star';
    },
  );

  return _InteractiveSelectableCard(
    title: title,
    description: description,
    isLocked: isLocked,
    hasBottomContent: hasBottomContent,
    icon: icon,
  );
}

class _InteractiveSelectableCard extends StatefulWidget {
  final String title;
  final String description;
  final bool isLocked;
  final bool hasBottomContent;
  final IconData icon;

  const _InteractiveSelectableCard({
    required this.title,
    required this.description,
    required this.isLocked,
    required this.hasBottomContent,
    required this.icon,
  });

  @override
  State<_InteractiveSelectableCard> createState() =>
      _InteractiveSelectableCardState();
}

class _InteractiveSelectableCardState
    extends State<_InteractiveSelectableCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return QuizdySelectableCard(
      icon: widget.icon,
      title: widget.title,
      description: widget.description,
      isSelected: _isSelected,
      isLocked: widget.isLocked,
      onTap: widget.isLocked ? null : () => setState(() => _isSelected = !_isSelected),
      bottomContent: widget.hasBottomContent
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Extra content shown when selected'),
            )
          : null,
    );
  }
}

class _SelectableCardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SelectableCardSection({required this.title, required this.child});

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
