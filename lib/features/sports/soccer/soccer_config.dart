import '../../../core/models/stat_type.dart';

/// Soccer-specific configuration
/// Contains default stat types and positions for soccer
class SoccerConfig {
  /// Get default stat types for soccer
  static List<StatType> getDefaultStatTypes() {
    return [
      StatType(key: 'completedPasses', label: 'Completed Passes'),
      StatType(key: 'interceptions', label: 'Interceptions'),
      StatType(key: 'turnovers', label: 'Turnovers'),
      StatType(key: 'tackles', label: 'Tackles'),
      StatType(key: 'fouls', label: 'Fouls'),
      StatType(key: 'shotsOnTarget', label: 'Shots on Target'),
      StatType(key: 'assists', label: 'Assists'),
      StatType(key: 'goals', label: 'Goals'),
      StatType(key: 'goalkeeperSaves', label: 'Goalkeeper Saves'),
      StatType(key: 'yellowCards', label: 'Yellow Cards'),
    ];
  }

  /// Get default positions for soccer
  static List<StatType> getDefaultPositions() {
    return [
      StatType(key: 'GK', label: 'Goalkeeper'),
      StatType(key: 'LB', label: 'Left Back'),
      StatType(key: 'RB', label: 'Right Back'),
      StatType(key: 'CB', label: 'Center Back'),
      StatType(key: 'LWB', label: 'Left Wing Back'),
      StatType(key: 'RWB', label: 'Right Wing Back'),
      StatType(key: 'CDM', label: 'Defensive Midfielder'),
      StatType(key: 'CM', label: 'Central Midfielder'),
      StatType(key: 'CAM', label: 'Attacking Midfielder'),
      StatType(key: 'LM', label: 'Left Midfielder'),
      StatType(key: 'RM', label: 'Right Midfielder'),
      StatType(key: 'LW', label: 'Left Winger'),
      StatType(key: 'RW', label: 'Right Winger'),
      StatType(key: 'ST', label: 'Striker'),
      StatType(key: 'CF', label: 'Center Forward'),
    ];
  }

  /// Sport identifier
  static const String sportId = 'soccer';
  
  /// Sport display name
  static const String sportName = 'Soccer';
}
