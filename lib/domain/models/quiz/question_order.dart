/// Represents the order in which questions are presented in a quiz.
enum QuestionOrder {
  /// Questions are randomized every time the quiz starts.
  random('random'),

  /// Questions are shown in their original creation order.
  ascending('ascending'),

  /// Questions are shown in reverse creation order.
  descending('descending');

  /// The internal string value used for serialization and persistence.
  final String value;

  const QuestionOrder(this.value);

  /// Returns the [QuestionOrder] corresponding to the given [value].
  ///
  /// If [value] is null or does not match any existing order,
  /// it defaults to [QuestionOrder.random].
  static QuestionOrder fromString(String? value) {
    if (value == null) return QuestionOrder.random;
    return QuestionOrder.values.firstWhere(
      (order) => order.value == value,
      orElse: () => QuestionOrder.random,
    );
  }
}
