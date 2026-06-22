/// Soccer-specific player model
/// This is a type alias for the existing Player model to maintain compatibility
/// while providing a soccer-specific namespace
/// 
/// In the future, this can be extended to add soccer-specific functionality
/// without breaking existing code
import '../../../../models/match_entry.dart';

/// Type alias for soccer players
/// Uses the existing Player model to maintain backward compatibility
typedef SoccerPlayer = Player;

/// Extension methods for soccer-specific functionality
extension SoccerPlayerExtensions on Player {
  /// Check if player is a goalkeeper
  bool get isGoalkeeper => position == 'GK';
  
  /// Check if player is a defender
  bool get isDefender => ['LB', 'RB', 'CB', 'LWB', 'RWB'].contains(position);
  
  /// Check if player is a midfielder
  bool get isMidfielder => ['CDM', 'CM', 'CAM', 'LM', 'RM'].contains(position);
  
  /// Check if player is a forward
  bool get isForward => ['LW', 'RW', 'ST', 'CF'].contains(position);
  
  /// Get total goals (first half + second half)
  int get totalGoals {
    final firstHalf = customStats['goals'] ?? 0;
    final secondHalf = secondHalfStats['goals'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total assists (first half + second half)
  int get totalAssists {
    final firstHalf = customStats['assists'] ?? 0;
    final secondHalf = secondHalfStats['assists'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total yellow cards (first half + second half)
  int get totalYellowCards {
    final firstHalf = customStats['yellowCards'] ?? 0;
    final secondHalf = secondHalfStats['yellowCards'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total saves (first half + second half)
  int get totalSaves {
    final firstHalf = customStats['goalkeeperSaves'] ?? 0;
    final secondHalf = secondHalfStats['goalkeeperSaves'] ?? 0;
    return firstHalf + secondHalf;
  }
}
