import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/services/configuration_service.dart';
import '../../../data/services/ai/ai_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/quiz/question.dart';
import '../../../domain/models/quiz/question_type.dart';

// Enum extendido para incluir la opción "random"
enum AiQuestionType {
  multipleChoice,
  singleChoice,
  trueFalse,
  essay,
  random, // Mezcla de todos los tipos
}

// Clase para la configuración de generación
class AiQuestionGenerationConfig {
  final int? questionCount;
  final AiQuestionType questionType;
  final String language;
  final String content;
  final AIService? preferredService; // Servicio preferido de IA

  const AiQuestionGenerationConfig({
    this.questionCount,
    required this.questionType,
    required this.language,
    required this.content,
    this.preferredService,
  });
}

class AiQuestionGenerationService {
  static const String _openaiApiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Genera preguntas usando IA basado en la configuración proporcionada
  Future<List<Question>> generateQuestions(
    AiQuestionGenerationConfig config, {
    AppLocalizations? localizations,
  }) async {
    try {
      // Si se especifica un servicio preferido, usarlo directamente
      if (config.preferredService != null && localizations != null) {
        return await _generateWithService(
          config,
          config.preferredService!,
          localizations,
        );
      }

      // Verificar que hay al menos una API key configurada
      final openaiKey = await ConfigurationService.instance.getOpenAIApiKey();
      final geminiKey = await ConfigurationService.instance.getGeminiApiKey();

      if ((openaiKey?.isEmpty ?? true) && (geminiKey?.isEmpty ?? true)) {
        throw Exception(
          'No hay ninguna clave API configurada para servicios de IA',
        );
      }

      // Intentar con OpenAI primero, luego con Gemini si falla
      if (openaiKey?.isNotEmpty == true) {
        try {
          return await _generateWithOpenAI(config, openaiKey!);
        } catch (e) {
          if (geminiKey?.isNotEmpty == true) {
            return await _generateWithGemini(config, geminiKey!);
          }
          rethrow;
        }
      } else if (geminiKey?.isNotEmpty == true) {
        return await _generateWithGemini(config, geminiKey!);
      }

      throw Exception('No se pudo generar preguntas con ningún servicio de IA');
    } catch (e) {
      throw Exception('Error al generar preguntas: ${e.toString()}');
    }
  }

  /// Genera preguntas usando el servicio de IA especificado
  Future<List<Question>> _generateWithService(
    AiQuestionGenerationConfig config,
    AIService aiService,
    AppLocalizations localizations,
  ) async {
    final prompt = _buildPrompt(config);

    try {
      final response = await aiService.getChatResponse(prompt, localizations);
      return _parseAiResponse(response);
    } catch (e) {
      throw Exception('Error con ${aiService.serviceName}: ${e.toString()}');
    }
  }

  /// Genera preguntas usando OpenAI
  Future<List<Question>> _generateWithOpenAI(
    AiQuestionGenerationConfig config,
    String apiKey,
  ) async {
    final prompt = _buildPrompt(config);

    final response = await http.post(
      Uri.parse(_openaiApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'Eres un experto en educación que crea preguntas de quiz de alta calidad. Responde ÚNICAMENTE con el JSON solicitado, sin texto adicional.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 3000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error en la API de OpenAI: ${response.statusCode} - ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body);
    final content = jsonResponse['choices'][0]['message']['content'];

    return _parseAiResponse(content);
  }

  /// Genera preguntas usando Gemini
  Future<List<Question>> _generateWithGemini(
    AiQuestionGenerationConfig config,
    String apiKey,
  ) async {
    final prompt = _buildPrompt(config);

    final response = await http.post(
      Uri.parse('$_geminiApiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Eres un experto en educación que crea preguntas de quiz de alta calidad. Responde ÚNICAMENTE con el JSON solicitado, sin texto adicional.\n\n$prompt',
              },
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 3000},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error en la API de Gemini: ${response.statusCode} - ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body);
    final content =
        jsonResponse['candidates'][0]['content']['parts'][0]['text'];

    return _parseAiResponse(content);
  }

  /// Construye el prompt para la IA
  String _buildPrompt(AiQuestionGenerationConfig config) {
    final questionCountText = config.questionCount != null
        ? 'exactamente ${config.questionCount}'
        : 'entre 3 y 8';

    final questionTypeText = _getQuestionTypePrompt(config.questionType);
    final languageText = _getLanguageName(config.language);

    return '''
Basándote en el siguiente contenido, genera $questionCountText preguntas de quiz $questionTypeText en $languageText.

CONTENIDO:
${config.content}

INSTRUCCIONES:
1. Las preguntas deben estar basadas específicamente en el contenido proporcionado
2. Cada pregunta debe tener exactamente 4 opciones de respuesta
3. Incluye una explicación clara para cada pregunta
4. Asegúrate de que las respuestas incorrectas sean plausibles pero claramente erróneas
5. Las explicaciones deben ser educativas y ayudar a entender por qué la respuesta es correcta

FORMATO DE RESPUESTA (JSON):
Responde ÚNICAMENTE con un array JSON válido en este formato exacto:
[
  {
    "text": "¿Pregunta aquí?",
    "type": "multiple_choice",
    "options": ["Opción A", "Opción B", "Opción C", "Opción D"],
    "correctAnswers": [0],
    "explanation": "Explicación detallada de por qué la respuesta A es correcta..."
  }
]

TIPOS DE PREGUNTA:
- "multiple_choice": Permite múltiples respuestas correctas
- "single_choice": Solo una respuesta correcta
- "true_false": Pregunta de verdadero/falso (opciones: ["Verdadero", "Falso"])
- "essay": Pregunta de ensayo (sin opciones)

$questionTypeText

¡IMPORTANTE!: Responde SOLO con el JSON, sin texto adicional antes o después.
''';
  }

  /// Obtiene el texto del prompt según el tipo de pregunta
  String _getQuestionTypePrompt(AiQuestionType type) {
    switch (type) {
      case AiQuestionType.multipleChoice:
        return 'Usa SOLO el tipo "multiple_choice" para todas las preguntas.';
      case AiQuestionType.singleChoice:
        return 'Usa SOLO el tipo "single_choice" para todas las preguntas.';
      case AiQuestionType.trueFalse:
        return 'Usa SOLO el tipo "true_false" para todas las preguntas. Las opciones deben ser ["Verdadero", "Falso"].';
      case AiQuestionType.essay:
        return 'Usa SOLO el tipo "essay" para todas las preguntas. No incluyas opciones.';
      case AiQuestionType.random:
        return 'Mezcla diferentes tipos de preguntas: "multiple_choice", "single_choice", "true_false", y "essay".';
    }
  }

  /// Obtiene el nombre del idioma
  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'es':
        return 'español';
      case 'en':
        return 'inglés';
      case 'fr':
        return 'francés';
      case 'de':
        return 'alemán';
      case 'it':
        return 'italiano';
      case 'pt':
        return 'portugués';
      default:
        return 'español';
    }
  }

  /// Parsea la respuesta de la IA y convierte a objetos Question
  List<Question> _parseAiResponse(String content) {
    try {
      // Limpiar la respuesta en caso de que tenga texto adicional
      String cleanContent = content.trim();

      // Buscar el JSON en la respuesta
      final startIndex = cleanContent.indexOf('[');
      final endIndex = cleanContent.lastIndexOf(']');

      if (startIndex == -1 || endIndex == -1) {
        throw Exception(
          'No se encontró un JSON válido en la respuesta de la IA',
        );
      }

      cleanContent = cleanContent.substring(startIndex, endIndex + 1);

      final List<dynamic> jsonList = jsonDecode(cleanContent);
      final List<Question> questions = [];

      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            final question = _createQuestionFromJson(item);
            questions.add(question);
          } catch (e) {
            // Si una pregunta falla, continuar con las demás
            // En producción, usar un logger apropiado
            continue;
          }
        }
      }

      if (questions.isEmpty) {
        throw Exception(
          'No se pudieron crear preguntas válidas a partir de la respuesta de la IA',
        );
      }

      return questions;
    } catch (e) {
      throw Exception(
        'Error al parsear la respuesta de la IA: ${e.toString()}',
      );
    }
  }

  /// Crea un objeto Question a partir de JSON
  Question _createQuestionFromJson(Map<String, dynamic> json) {
    final questionType = QuestionType.fromString(
      json['type'] ?? 'multiple_choice',
    );

    List<String> options = [];
    if (json['options'] != null) {
      options = List<String>.from(json['options']);
    } else if (questionType == QuestionType.trueFalse) {
      options = ['Verdadero', 'Falso'];
    }

    List<int> correctAnswers = [];
    if (json['correctAnswers'] != null) {
      correctAnswers = List<int>.from(json['correctAnswers']);
    } else if (questionType == QuestionType.trueFalse) {
      // Para true/false, asumir que la primera opción es correcta si no se especifica
      correctAnswers = [0];
    }

    return Question(
      type: questionType,
      text: json['text'] ?? '',
      options: options,
      correctAnswers: correctAnswers,
      explanation: json['explanation'] ?? '',
      image: null, // La IA no genera imágenes por ahora
    );
  }
}
