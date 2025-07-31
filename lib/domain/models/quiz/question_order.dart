enum QuestionOrder {
  ascending('ascending'),
  descending('descending'),
  random('random');

  const QuestionOrder(this.value);
  final String value;

  static QuestionOrder fromString(String value) {
    return QuestionOrder.values.firstWhere(
      (order) => order.value == value,
      orElse: () => QuestionOrder.random,
    );
  }
}
