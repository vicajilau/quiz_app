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

import 'package:flutter/material.dart';
import 'package:quizdy/core/context_extension.dart';

class QuizdyEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const QuizdyEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.library_books_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = !context.isMobile;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isLarge ? 64.0 : 48.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isLarge ? 80 : 64,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
                SizedBox(height: isLarge ? 24 : 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style:
                      (isLarge
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.bodyLarge)
                          ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
