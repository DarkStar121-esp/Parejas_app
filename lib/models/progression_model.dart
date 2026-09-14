import 'dart:math';

class ProgressionModel {
  int level;
  int currentXp;
  int streakDays;
  DateTime? lastPlayedDate;

  ProgressionModel({
    this.level = 1,
    this.currentXp = 0,
    this.streakDays = 0,
    this.lastPlayedDate,
  });

  static int xpForLevel(int level) => 100 * level;

  int calculateActiveXp() {
    final bonus = (streakDays * 2).clamp(0, 30);
    return 20 + bonus;
  }

  void addPassiveXp() {
    addXp(5);
  }

  void recordGamePlayed() {
    final now = DateTime.now();
    if (lastPlayedDate != null) {
      final difference = now.difference(lastPlayedDate!).inDays;
      if (difference == 1) {
        streakDays++;
      } else if (difference > 1) {
        streakDays = 0;
      }
    } else {
      streakDays = 1;
    }
    lastPlayedDate = now;

    final earnedXp = calculateActiveXp();
    addXp(earnedXp);
  }

  void addXp(int xp) {
    currentXp += xp;
    while (currentXp >= xpForLevel(level)) {
      currentXp -= xpForLevel(level);
      level++;
    }
  }

  static String getRewardForLevel(int level) {
    if (level % 2 == 0) {
      return '1 animal para cada uno';
    } else if (level % 3 == 0) {
      return '1 tipografía nueva';
    } else if (level % 5 == 0) {
      return '1 color de banner';
    }
    return 'Recompensa de nivel';
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentXp': currentXp,
      'streakDays': streakDays,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    };
  }

  factory ProgressionModel.fromMap(Map<String, dynamic> map) {
    return ProgressionModel(
      level: map['level'] ?? 1,
      currentXp: map['currentXp'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      lastPlayedDate: DateTime.tryParse(map['lastPlayedDate'] ?? ''),
    );
  }
}
