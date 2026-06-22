import '../../../core/models/stat_type.dart';

/// Basketball-specific configuration
/// Contains default stat types and positions for basketball
class BasketballConfig {
  /// Get default stat types for basketball
  static List<StatType> getDefaultStatTypes() {
    return [
      StatType(key: 'points', label: 'Points'),
      StatType(key: 'assists', label: 'Assists'),
      StatType(key: 'rebounds', label: 'Rebounds'),
      StatType(key: 'steals', label: 'Steals'),
      StatType(key: 'blocks', label: 'Blocks'),
      StatType(key: 'turnovers', label: 'Turnovers'),
      StatType(key: 'fouls', label: 'Fouls'),
      StatType(key: 'threePointers', label: '3-Pointers'),
      StatType(key: 'freeThrows', label: 'Free Throws'),
      StatType(key: 'fieldGoals', label: 'Field Goals'),
    ];
  }

  /// Get default positions for basketball
  static List<StatType> getDefaultPositions() {
    return [
      StatType(key: 'PG', label: 'Point Guard'),
      StatType(key: 'SG', label: 'Shooting Guard'),
      StatType(key: 'SF', label: 'Small Forward'),
      StatType(key: 'PF', label: 'Power Forward'),
      StatType(key: 'C', label: 'Center'),
      StatType(key: 'G', label: 'Guard'),
      StatType(key: 'F', label: 'Forward'),
      StatType(key: 'GF', label: 'Guard-Forward'),
      StatType(key: 'FC', label: 'Forward-Center'),
    ];
  }

  /// Sport identifier
  static const String sportId = 'basketball';
  
  /// Sport display name
  static const String sportName = 'Basketball';
}
