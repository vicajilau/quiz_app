import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/quiz/question_order.dart';

class ConfigurationService {
  static const String _questionOrderKey = 'question_order';

  static ConfigurationService? _instance;
  static ConfigurationService get instance =>
      _instance ??= ConfigurationService._();

  ConfigurationService._();

  /// Guarda el orden de preguntas seleccionado en SharedPreferences
  Future<void> saveQuestionOrder(QuestionOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questionOrderKey, order.value);
  }

  /// Obtiene el orden de preguntas guardado, por defecto es aleatorio
  Future<QuestionOrder> getQuestionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderValue = prefs.getString(_questionOrderKey);

    if (orderValue != null) {
      return QuestionOrder.fromString(orderValue);
    }

    return QuestionOrder.random; // Valor por defecto
  }
}
