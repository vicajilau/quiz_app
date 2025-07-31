import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/question_constants.dart';

/// Utility class for translating question-related content in the presentation layer
class QuestionTranslationHelper {
  /// Translates option text from data layer to presentation layer
  /// This handles the translation of True/False options from the model to localized strings
  static String translateOption(String option, AppLocalizations localizations) {
    switch (option) {
      case QuestionConstants.defaultTrueOption:
        return localizations.trueLabel;
      case QuestionConstants.defaultFalseOption:
        return localizations.falseLabel;
      default:
        return option; // Return as-is for custom options
    }
  }
}
