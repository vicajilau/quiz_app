/// Represents the metadata of a Quiz file.
class QuizMetadata {
  /// The title of the quiz.
  final String title;

  /// The description of the quiz.
  final String description;

  /// The version of the quiz file format.
  final String version;

  /// The author of the quiz.
  final String author;

  /// Constructor for creating a `QuizMetadata` instance.
  const QuizMetadata({
    required this.title,
    required this.description,
    required this.version,
    required this.author,
  });

  /// Creates a `QuizMetadata` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the metadata.
  /// - Returns: A `QuizMetadata` instance populated with the data from the JSON.
  factory QuizMetadata.fromJson(Map<String, dynamic> json) {
    return QuizMetadata(
      title: json['title'] ?? 'Untitled Quiz',
      description: json['description'] ?? '',
      version: json['version'] ?? '1.0',
      author: json['author'] ?? 'Unknown',
    );
  }

  /// Converts the `QuizMetadata` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation of the metadata.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'version': version,
      'author': author,
    };
  }

  /// Creates a copy of the `QuizMetadata` with optional parameter modifications.
  ///
  /// - [title]: New title to replace the current one.
  /// - [description]: New description to replace the current one.
  /// - [version]: New version to replace the current one.
  /// - [author]: New author to replace the current one.
  /// - Returns: A new `QuizMetadata` instance with the specified modifications.
  QuizMetadata copyWith({
    String? title,
    String? description,
    String? version,
    String? author,
  }) {
    return QuizMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizMetadata &&
        other.title == title &&
        other.description == description &&
        other.version == version &&
        other.author == author;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        version.hashCode ^
        author.hashCode;
  }

  @override
  String toString() {
    return 'QuizMetadata(title: $title, description: $description, version: $version, author: $author)';
  }
}
