/// The Metadata class represents the metadata of a MASO file, including its name, version, and description.
class Metadata {
  /// The name of the MASO file
  final String name;

  /// The version of the MASO file
  final String version;

  /// A description of the MASO file
  final String description;

  /// Constructor for creating a Metadata instance with name, version, and description.
  Metadata({
    required this.name,
    required this.version,
    required this.description,
  });

  /// Factory constructor to create a Metadata instance from a JSON map.
  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        name: json['name'] as String, // Parse the 'name' field
        version: json['version'] as String, // Parse the 'version' field
        description:
            json['description'] as String, // Parse the 'description' field
      );

  /// Converts the Metadata instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'name': name, // Convert the 'name' field to JSON
        'version': version, // Convert the 'version' field to JSON
        'description': description, // Convert the 'description' field to JSON
      };

  /// Override the equality operator to compare Metadata instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Metadata &&
        other.name == name &&
        other.version == version &&
        other.description == description;
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode => name.hashCode ^ version.hashCode ^ description.hashCode;

  @override
  String toString() =>
      "Metadata {name: $name, version: $version, description: $description}";
}
