/// Basketball-specific player model
/// This is a type alias for the existing Player model to maintain compatibility
/// while providing a basketball-specific namespace
/// 
/// In the future, this can be extended to add basketball-specific functionality
/// without breaking existing code
import '../../../../models/match_entry.dart';

/// Type alias for basketball players
/// Uses the existing Player model to maintain backward compatibility
typedef BasketballPlayer = Player;

/// Extension methods for basketball-specific functionality
extension BasketballPlayerExtensions on Player {
  /// Check if player is a guard
  bool get isGuard => ['PG', 'SG', 'G', 'GF'].contains(position);
  
  /// Check if player is a forward
  bool get isForward => ['SF', 'PF', 'F', 'GF', 'FC'].contains(position);
  
  /// Check if player is a center
  bool get isCenter => ['C', 'FC'].contains(position);
  
  /// Get total points (first half + second half)
  int get totalPoints {
    final firstHalf = customStats['points'] ?? 0;
    final secondHalf = secondHalfStats['points'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total assists (first half + second half)
  int get totalAssists {
    final firstHalf = customStats['assists'] ?? 0;
    final secondHalf = secondHalfStats['assists'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total rebounds (first half + second half)
  int get totalRebounds {
    final firstHalf = customStats['rebounds'] ?? 0;
    final secondHalf = secondHalfStats['rebounds'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total steals (first half + second half)
  int get totalSteals {
    final firstHalf = customStats['steals'] ?? 0;
    final secondHalf = secondHalfStats['steals'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total blocks (first half + second half)
  int get totalBlocks {
    final firstHalf = customStats['blocks'] ?? 0;
    final secondHalf = secondHalfStats['blocks'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total turnovers (first half + second half)
  int get totalTurnovers {
    final firstHalf = customStats['turnovers'] ?? 0;
    final secondHalf = secondHalfStats['turnovers'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Get total three pointers (first half + second half)
  int get totalThreePointers {
    final firstHalf = customStats['threePointers'] ?? 0;
    final secondHalf = secondHalfStats['threePointers'] ?? 0;
    return firstHalf + secondHalf;
  }
  
  /// Calculate points per game (if multiple games tracked)
  double pointsPerGame(int gamesPlayed) {
    if (gamesPlayed == 0) return 0.0;
    return totalPoints / gamesPlayed;
  }
  
  /// Calculate field goal percentage (if tracked)
  double? fieldGoalPercentage() {
    final made = totalPoints; // Simplified - would need attempts tracked
    // This is a placeholder - actual implementation would need FG attempts
    return null;
  }
}
