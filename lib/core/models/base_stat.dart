/// Base stat model for representing statistical data
/// 
/// This class is used to define stat types with a key (for storage)
/// and a label (for display).
class BaseStat {
  final String key;
  final String label;
  final int value;

  BaseStat({
    required this.key,
    required this.label,
    this.value = 0,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'value': value,
      };

  /// Create from JSON
  factory BaseStat.fromJson(Map<String, dynamic> json) => BaseStat(
        key: json['key'] as String,
        label: json['label'] as String,
        value: json['value'] as int? ?? 0,
      );

  /// Create a copy with optional replacements
  BaseStat copyWith({
    String? key,
    String? label,
    int? value,
  }) {
    return BaseStat(
      key: key ?? this.key,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'BaseStat(key: $key, label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseStat &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ label.hashCode ^ value.hashCode;
}
