class ChatMessage {
  final String content;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
