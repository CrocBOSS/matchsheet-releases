/// Base player model that all sport and training players can extend
/// 
/// This abstract class defines the common properties and methods
/// that all player types share across the application.
abstract class BasePlayer {
  final int id;
  final int number;
  final String name;
  final String position;
  final String teamName;
  final String comments;
  final int rating;

  BasePlayer({
    required this.id,
    required this.number,
    required this.name,
    required this.position,
    this.teamName = '',
    this.comments = '',
    this.rating = 0,
  });

  /// Convert player to JSON for storage
  Map<String, dynamic> toJson();

  /// Common display name format: "number - name"
  String get displayName => '$number - $name';

  /// Check if player has a rating
  bool get hasRating => rating > 0;

  /// Check if player has comments
  bool get hasComments => comments.isNotEmpty;

  /// Get rating display string
  String get ratingDisplay => rating > 0 ? '$rating/10' : '-';
}
