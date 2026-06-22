import '../../../../core/models/stat_type.dart';

class TechnicalSkill {
  final String key;
  final String label;
  final double targetScore;
  final int totalReps;
  final String unit;

  TechnicalSkill({
    required this.key,
    required this.label,
    required this.targetScore,
    required this.totalReps,
    this.unit = 'reps',
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'targetScore': targetScore,
      'totalReps': totalReps,
      'unit': unit,
    };
  }

  factory TechnicalSkill.fromJson(Map<String, dynamic> json) {
    return TechnicalSkill(
      key: json['key'] as String,
      label: json['label'] as String,
      targetScore: (json['targetScore'] as num?)?.toDouble() ?? 5.0,
      totalReps: json['totalReps'] as int? ?? 10,
      unit: json['unit'] as String? ?? 'reps',
    );
  }

  StatType toStatType() {
    return StatType(key: key, label: label);
  }

  TechnicalSkill copyWith({
    String? key,
    String? label,
    double? targetScore,
    int? totalReps,
    String? unit,
  }) {
    return TechnicalSkill(
      key: key ?? this.key,
      label: label ?? this.label,
      targetScore: targetScore ?? this.targetScore,
      totalReps: totalReps ?? this.totalReps,
      unit: unit ?? this.unit,
    );
  }
}
