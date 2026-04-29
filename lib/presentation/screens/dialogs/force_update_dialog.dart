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
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

/// A non-dismissable dialog shown when the installed version is below the
/// minimum supported version. The user must update to continue using the app.
class ForceUpdateDialog extends StatelessWidget {
  final VoidCallback onUpdatePressed;

  const ForceUpdateDialog({super.key, required this.onUpdatePressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.forceUpdateTitle),
        content: Text(l10n.forceUpdateMessage),
        actions: [
          QuizdyButton(title: l10n.updateButton, onPressed: onUpdatePressed),
        ],
      ),
    );
  }
}
