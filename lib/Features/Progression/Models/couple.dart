import 'dart:math';

enum RelationshipType { dating, partners, lovers, married }

class Couple {
  final String id;
  final String user1Uid;
  final String user2Uid;
  final RelationshipType relationshipType;
  final DateTime relationshipStartDate;
  final DateTime pairedAt;

  int xp;
  int level;
  int streakDays;
  DateTime lastActiveDate;

  List<String> coupleUnlockedFonts;
  List<String> coupleUnlockedBanners;

  Couple({
    required this.id,
    required this.user1Uid,
    required this.user2Uid,
    required this.relationshipType,
    required this.relationshipStartDate,
    required this.pairedAt,
    this.xp = 0,
    this.level = 1,
    this.streakDays = 0,
    required this.lastActiveDate,
    required this.coupleUnlockedFonts,
    required this.coupleUnlockedBanners,
  });

  int get requiredXpForNextLevel => 100 * level;

  void addGameXp() {
    final activeXp = 20 + min(streakDays * 2, 30);
    xp += activeXp;
    _checkLevelUp();
  }

  void _checkLevelUp() {
    while (xp >= requiredXpForNextLevel) {
      xp -= requiredXpForNextLevel;
      level++;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Uid': user1Uid,
      'user2Uid': user2Uid,
      'relationshipType': relationshipType.name,
      'relationshipStartDate': relationshipStartDate.toIso8601String(),
      'pairedAt': pairedAt.toIso8601String(),
      'xp': xp,
      'level': level,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'coupleUnlockedFonts': coupleUnlockedFonts,
      'coupleUnlockedBanners': coupleUnlockedBanners,
    };
  }
}
