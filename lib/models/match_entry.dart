class Player {
  final int id;
  final int number;
  final String name;
  String teamName; // Team name (primarily used for the first player)
  String position; // Player position (GK, LB, RB, CB, etc.)
  int completedPasses;
  int interceptions;
  int turnovers;
  int tackles;
  int fouls;
  int shotsOnTarget;
  int assists;
  int goals;
  int goalkeeperSaves;
  int yellowCards;
  String comments;
  int rating; // Player rating from 1-10
  Map<String, int> customStats; // Store custom stat values
  Map<String, int> secondHalfStats; // Store second half stats

  Player({
    required this.id,
    required this.number,
    required this.name,
    this.teamName = 'Team A',
    this.position = '',
    this.completedPasses = 0,
    this.interceptions = 0,
    this.turnovers = 0,
    this.tackles = 0,
    this.fouls = 0,
    this.shotsOnTarget = 0,
    this.assists = 0,
    this.goals = 0,
    this.goalkeeperSaves = 0,
    this.yellowCards = 0,
    this.comments = '',
    this.rating = 0,
    Map<String, int>? customStats,
    Map<String, int>? secondHalfStats,
  }) : customStats = customStats ?? {},
       secondHalfStats = secondHalfStats ?? {};

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'number': number,
      'name': name,
      'teamName': teamName,
      'position': position,
      'completedPasses': completedPasses,
      'interceptions': interceptions,
      'turnovers': turnovers,
      'tackles': tackles,
      'fouls': fouls,
      'shotsOnTarget': shotsOnTarget,
      'assists': assists,
      'goals': goals,
      'goalkeeperSaves': goalkeeperSaves,
      'yellowCards': yellowCards,
      'rating': rating,
    };
    // Merge custom stats into the main json
    json.addAll(customStats);
    // Add second half stats
    json['secondHalfStats'] = secondHalfStats;
    // Add comments last
    json['comments'] = comments;
    return json;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    // Standard fields that should NOT be included in customStats
    final standardFields = {
      'id', 'number', 'name', 'teamName', 'position', 
      'comments', 'rating', 'secondHalfStats'
    };
    
    // Extract custom stats (any integer fields not in standard list)
    // This includes the stat fields like completedPasses, interceptions, etc.
    final customStats = <String, int>{};
    for (final entry in json.entries) {
      if (!standardFields.contains(entry.key) && entry.value is int) {
        customStats[entry.key] = entry.value as int;
      }
    }
    
    return Player(
      id: json['id'] as int,
      number: json['number'] as int,
      name: json['name'] as String,
      teamName: json['teamName'] as String? ?? 'Team A',
      position: json['position'] as String? ?? '',
      completedPasses: 0,  // Always 0, actual value in customStats
      interceptions: 0,     // Always 0, actual value in customStats
      turnovers: 0,         // Always 0, actual value in customStats
      tackles: 0,           // Always 0, actual value in customStats
      fouls: 0,             // Always 0, actual value in customStats
      shotsOnTarget: 0,     // Always 0, actual value in customStats
      assists: 0,           // Always 0, actual value in customStats
      goals: 0,             // Always 0, actual value in customStats
      goalkeeperSaves: 0,   // Always 0, actual value in customStats
      yellowCards: 0,       // Always 0, actual value in customStats
      comments: json['comments'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      customStats: customStats,
      secondHalfStats: (json['secondHalfStats'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
    );
  }

  Player copyWith({
    int? id,
    int? number,
    String? name,
    String? teamName,
    String? position,
    int? completedPasses,
    int? interceptions,
    int? turnovers,
    int? tackles,
    int? fouls,
    int? shotsOnTarget,
    int? assists,
    int? goals,
    int? goalkeeperSaves,
    int? yellowCards,
    String? comments,
    int? rating,
    Map<String, int>? customStats,
    Map<String, int>? secondHalfStats,
  }) {
    return Player(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      teamName: teamName ?? this.teamName,
      position: position ?? this.position,
      completedPasses: completedPasses ?? this.completedPasses,
      interceptions: interceptions ?? this.interceptions,
      turnovers: turnovers ?? this.turnovers,
      tackles: tackles ?? this.tackles,
      fouls: fouls ?? this.fouls,
      shotsOnTarget: shotsOnTarget ?? this.shotsOnTarget,
      assists: assists ?? this.assists,
      goals: goals ?? this.goals,
      goalkeeperSaves: goalkeeperSaves ?? this.goalkeeperSaves,
      yellowCards: yellowCards ?? this.yellowCards,
      comments: comments ?? this.comments,
      rating: rating ?? this.rating,
      customStats: customStats ?? this.customStats,
      secondHalfStats: secondHalfStats ?? this.secondHalfStats,
    );
  }
}
