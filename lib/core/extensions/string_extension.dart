import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String languageName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return toUpperCase();

    switch (this) {
      case 'es':
        return localizations.languageSpanish;
      case 'en':
        return localizations.languageEnglish;
      case 'fr':
        return localizations.languageFrench;
      case 'de':
        return localizations.languageGerman;
      case 'el':
        return localizations.languageGreek;
      case 'it':
        return localizations.languageItalian;
      case 'pt':
        return localizations.languagePortuguese;
      case 'ca':
        return localizations.languageCatalan;
      case 'eu':
        return localizations.languageBasque;
      case 'gl':
        return localizations.languageGalician;
      case 'hi':
        return localizations.languageHindi;
      case 'zh':
        return localizations.languageChinese;
      case 'ar':
        return localizations.languageArabic;
      case 'ja':
        return localizations.languageJapanese;
      default:
        return toUpperCase(); // Fallback to uppercase code
    }
  }
}
