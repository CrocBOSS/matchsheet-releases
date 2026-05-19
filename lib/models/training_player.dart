class TrainingPlayer {
  final String id; // Unique identifier (UUID)
  final String name;
  final int number;
  final String position;
  final DateTime createdDate;

  TrainingPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'position': position,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TrainingPlayer.fromJson(Map<String, dynamic> json) {
    return TrainingPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      position: json['position'] as String,
      createdDate: json['createdDate'] != null 
          ? DateTime.parse(json['createdDate'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with optional replacements
  TrainingPlayer copyWith({
    String? id,
    String? name,
    int? number,
    String? position,
    DateTime? createdDate,
  }) {
    return TrainingPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      position: position ?? this.position,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  String toString() => 'TrainingPlayer(id: $id, name: $name, number: $number, position: $position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPlayer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
