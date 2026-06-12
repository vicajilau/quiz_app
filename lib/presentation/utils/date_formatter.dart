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

class DateFormatter {
  static String formatLastOpened(BuildContext context, DateTime lastOpened) {
    final now = DateTime.now();
    final difference = now.difference(lastOpened);
    final localizations = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      if (lastOpened.day == now.day) {
        return localizations.homeRecentToday;
      } else {
        return localizations.homeRecentYesterday;
      }
    } else if (difference.inDays == 1) {
      return localizations.homeRecentYesterday;
    } else if (difference.inDays < 7) {
      return localizations.homeRecentDaysAgo(difference.inDays.toString());
    } else {
      return '${lastOpened.day.toString().padLeft(2, '0')}/${lastOpened.month.toString().padLeft(2, '0')}/${lastOpened.year}';
    }
  }
}
