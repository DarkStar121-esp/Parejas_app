enum RelationshipType { saliendo, novios, amantes, esposos }

class CoupleModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final RelationshipType relationshipType;
  final DateTime relationshipStartDate;
  final DateTime pairedAt;

  CoupleModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.relationshipType,
    required this.relationshipStartDate,
    required this.pairedAt,
  });

  // Cálculo del tiempo transcurrido en la relación
  Duration get durationTogether => DateTime.now().difference(relationshipStartDate);

  String get timeTogetherFormatted {
    final days = durationTogether.inDays;
    if (days < 30) return '$days días juntos';
    final months = (days / 30).floor();
    if (months < 12) return '$months meses juntos';
    final years = (months / 12).floor();
    final remainingMonths = months % 12;
    return remainingMonths > 0 
        ? '$years años y $remainingMonths meses juntos' 
        : '$years años juntos';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'relationshipType': relationshipType.name,
      'relationshipStartDate': relationshipStartDate.toIso8601String(),
      'pairedAt': pairedAt.toIso8601String(),
    };
  }

  factory CoupleModel.fromMap(Map<String, dynamic> map) {
    return CoupleModel(
      id: map['id'] ?? '',
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      relationshipType: RelationshipType.values.firstWhere(
        (e) => e.name == map['relationshipType'],
        orElse: () => RelationshipType.novios,
      ),
      relationshipStartDate: DateTime.tryParse(map['relationshipStartDate'] ?? '') ?? DateTime.now(),
      pairedAt: DateTime.tryParse(map['pairedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
