/// Model representing a single speed training attempt
/// 
/// Stores the time recorded, whether it met the target,
/// and timestamp for a single sprint attempt.
class SpeedAttempt {
  /// The sequential number of this attempt (1, 2, 3, ...)
  final int attemptNumber;
  
  /// Time recorded in milliseconds
  final int timeInMilliseconds;
  
  /// Whether this attempt met the target time
  final bool metTarget;
  
  /// When this attempt was recorded
  final DateTime timestamp;

  SpeedAttempt({
    required this.attemptNumber,
    required this.timeInMilliseconds,
    required this.metTarget,
    required this.timestamp,
  });

  /// Returns formatted time string in MM:SS.mmm format
  /// 
  /// Example: 12345 milliseconds → "00:12.345"
  String get formattedTime {
    final minutes = (timeInMilliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((timeInMilliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (timeInMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }

  /// Returns the time difference from target as a formatted string
  /// 
  /// Returns format: "+X.XXXs" or "-X.XXXs"
  /// Example: 500ms over target → "+0.500s"
  ///          300ms under target → "-0.300s"
  String getDifferenceFromTarget(int targetInMillis) {
    final diff = timeInMilliseconds - targetInMillis;
    final sign = diff > 0 ? '+' : (diff < 0 ? '-' : '');
    final seconds = (diff.abs() / 1000).toStringAsFixed(3);
    return '$sign${seconds}s';
  }

  /// Converts this attempt to a JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'attemptNumber': attemptNumber,
      'timeInMilliseconds': timeInMilliseconds,
      'metTarget': metTarget,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a SpeedAttempt from a JSON map
  factory SpeedAttempt.fromJson(Map<String, dynamic> json) {
    return SpeedAttempt(
      attemptNumber: json['attemptNumber'] as int,
      timeInMilliseconds: json['timeInMilliseconds'] as int,
      metTarget: json['metTarget'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Creates a copy of this attempt with optional field updates
  SpeedAttempt copyWith({
    int? attemptNumber,
    int? timeInMilliseconds,
    bool? metTarget,
    DateTime? timestamp,
  }) {
    return SpeedAttempt(
      attemptNumber: attemptNumber ?? this.attemptNumber,
      timeInMilliseconds: timeInMilliseconds ?? this.timeInMilliseconds,
      metTarget: metTarget ?? this.metTarget,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'SpeedAttempt(#$attemptNumber: $formattedTime, metTarget: $metTarget)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeedAttempt &&
        other.attemptNumber == attemptNumber &&
        other.timeInMilliseconds == timeInMilliseconds &&
        other.metTarget == metTarget &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      attemptNumber,
      timeInMilliseconds,
      metTarget,
      timestamp,
    );
  }
}
