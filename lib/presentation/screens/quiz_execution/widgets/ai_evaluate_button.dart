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
import 'package:quizdy/core/l10n/app_localizations.dart';
/// A button that triggers AI evaluation of an essay answer.
class AiEvaluateButton extends StatelessWidget {
  /// Whether an evaluation is currently in progress.
  final bool isEvaluating;

  /// Callback when the button is pressed.
  final VoidCallback onEvaluate;

  /// Creates an [AiEvaluateButton].
  const AiEvaluateButton({
    super.key,
    required this.isEvaluating,
    required this.onEvaluate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: isEvaluating ? null : onEvaluate,
        icon: isEvaluating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          isEvaluating
              ? AppLocalizations.of(context)!.aiThinking
              : AppLocalizations.of(context)!.evaluateWithAI,
          style: const TextStyle(fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
