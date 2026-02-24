class StatType {
  final String key;
  final String label;

  StatType({required this.key, required this.label});

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }

  factory StatType.fromJson(Map<String, dynamic> json) {
    return StatType(
      key: json['key'] as String,
      label: json['label'] as String,
    );
  }

  StatType copyWith({String? key, String? label}) {
    return StatType(
      key: key ?? this.key,
      label: label ?? this.label,
    );
  }
}
