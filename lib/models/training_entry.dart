class TrainingEntry {
  final int id;
  final String playerId; // Link to TrainingPlayer profile
  final int playerNumber;
  final String playerName;
  final String position;
  String trainingType; // "strength_condition" or "technical_performance"
  String notes;
  DateTime date;
  Map<String, dynamic> customStats; // Store custom training stats

  TrainingEntry({
    required this.id,
    required this.playerId,
    required this.playerNumber,
    required this.playerName,
    required this.position,
    required this.trainingType,
    this.notes = '',
    DateTime? date,
    Map<String, dynamic>? customStats,
  }) : date = date ?? DateTime.now(),
       customStats = customStats ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'playerNumber': playerNumber,
      'playerName': playerName,
      'position': position,
      'trainingType': trainingType,
      'notes': notes,
      'date': date.toIso8601String(),
      'customStats': customStats,
    };
  }

  factory TrainingEntry.fromJson(Map<String, dynamic> json) {
    return TrainingEntry(
      id: json['id'] as int,
      playerId: json['playerId'] as String? ?? '',
      playerNumber: json['playerNumber'] as int,
      playerName: json['playerName'] as String,
      position: json['position'] as String? ?? '',
      trainingType: json['trainingType'] as String,
      notes: json['notes'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      customStats: Map<String, dynamic>.from(
        (json['customStats'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  TrainingEntry copyWith({
    int? id,
    String? playerId,
    int? playerNumber,
    String? playerName,
    String? position,
    String? trainingType,
    String? notes,
    DateTime? date,
    Map<String, dynamic>? customStats,
  }) {
    return TrainingEntry(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerNumber: playerNumber ?? this.playerNumber,
      playerName: playerName ?? this.playerName,
      position: position ?? this.position,
      trainingType: trainingType ?? this.trainingType,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      customStats: customStats ?? this.customStats,
    );
  }
}
