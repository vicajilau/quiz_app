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
import 'package:quizdy/presentation/widgets/quizdy_empty_state.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyEmptyState)
Widget buildQuizdyEmptyStateUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _EmptyStateCard(
          title: 'Default icon',
          child: const QuizdyEmptyState(message: 'No quizzes found'),
        ),
        const SizedBox(height: 10.0),
        _EmptyStateCard(
          title: 'Custom icon — search',
          child: const QuizdyEmptyState(
            message: 'No results for your search',
            icon: Icons.search_off_outlined,
          ),
        ),
        const SizedBox(height: 10.0),
        _EmptyStateCard(
          title: 'Custom icon — history',
          child: const QuizdyEmptyState(
            message: 'No recent activity yet',
            icon: Icons.history_outlined,
          ),
        ),
        const SizedBox(height: 10.0),
        _EmptyStateCard(
          title: 'Custom icon — notifications',
          child: const QuizdyEmptyState(
            message: "You're all caught up!",
            icon: Icons.notifications_none_outlined,
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyEmptyState)
Widget buildInteractiveQuizdyEmptyStateUseCase(BuildContext context) {
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'Nothing here yet',
  );
  final icon = context.knobs.object.dropdown<IconData>(
    label: 'Icon',
    options: [
      Icons.library_books_outlined,
      Icons.search_off_outlined,
      Icons.history_outlined,
      Icons.notifications_none_outlined,
      Icons.folder_open_outlined,
      Icons.inbox_outlined,
    ],
    initialOption: Icons.library_books_outlined,
    labelBuilder: (i) {
      if (i == Icons.library_books_outlined) return 'Library books';
      if (i == Icons.search_off_outlined) return 'Search off';
      if (i == Icons.history_outlined) return 'History';
      if (i == Icons.notifications_none_outlined) return 'Notifications';
      if (i == Icons.folder_open_outlined) return 'Folder open';
      return 'Inbox';
    },
  );

  return QuizdyEmptyState(message: message, icon: icon);
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _EmptyStateCard({required this.title, required this.child});

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
            child,
          ],
        ),
      ),
    );
  }
}
