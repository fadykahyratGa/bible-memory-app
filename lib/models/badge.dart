class Badge {
  final String id;
  final String nameAr;
  final String descriptionAr;
  final String iconKey;
  final String conditionType;
  final int conditionValue;
  final bool unlocked;

  const Badge({
    required this.id,
    required this.nameAr,
    required this.descriptionAr,
    required this.iconKey,
    required this.conditionType,
    required this.conditionValue,
    this.unlocked = false,
  });

  factory Badge.fromMap(Map<String, dynamic> map, {Set<String>? unlockedIds}) {
    final isUnlocked = unlockedIds?.contains(map['id']) ?? false;
    return Badge(
      id: map['id'] as String,
      nameAr: map['name_ar'] as String,
      descriptionAr: map['description_ar'] as String,
      iconKey: map['icon_key'] as String,
      conditionType: map['condition_type'] as String,
      conditionValue: map['condition_value'] as int,
      unlocked: isUnlocked,
    );
  }
}
