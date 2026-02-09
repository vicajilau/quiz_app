import 'package:hive_ce/hive.dart';

/// Enum representing the mode in which a quiz was taken.
enum QuizMode {
  /// Study mode allows checking answers during the quiz.
  study,

  /// Exam mode requires completing the quiz before seeing results.
  exam;

  /// Creates a QuizMode from a boolean value.
  /// true = study mode, false = exam mode
  static QuizMode fromBool(bool isStudyMode) {
    return isStudyMode ? QuizMode.study : QuizMode.exam;
  }

  /// Converts to boolean for compatibility with existing code.
  bool get isStudyMode => this == QuizMode.study;
}

/// Hive TypeAdapter for QuizMode enum.
class QuizModeAdapter extends TypeAdapter<QuizMode> {
  @override
  final int typeId = 0;

  @override
  QuizMode read(BinaryReader reader) {
    final index = reader.readByte();
    return QuizMode.values[index];
  }

  @override
  void write(BinaryWriter writer, QuizMode obj) {
    writer.writeByte(obj.index);
  }
}
