class MatchHistoryModel {
  int user1Wins;
  int user2Wins;
  DateTime? lastCompetitiveMatchDate;

  MatchHistoryModel({
    this.user1Wins = 0,
    this.user2Wins = 0,
    this.lastCompetitiveMatchDate,
  });

  // Registrar resultado de una partida competitiva (isCompetitive == true)
  void recordMatchResult({required String winnerUserId, required String user1Id}) {
    if (winnerUserId == user1Id) {
      user1Wins++;
    } else {
      user2Wins++;
    }
    lastCompetitiveMatchDate = DateTime.now();
  }

  // Chequeo de inactividad por 30 días
  bool get isNicknameActive {
    if (lastCompetitiveMatchDate == null) return false;
    final daysInactive = DateTime.now().difference(lastCompetitiveMatchDate!).inDays;
    return daysInactive <= 30;
  }

  // 7. Cálculo dinámico de apodos (no se guarda, se evalúa en caliente)
  String? getNicknameForUser(String userId, String user1Id) {
    if (!isNicknameActive) return null; // Reset a neutro por inactividad (> 30 días)
    if (user1Wins == user2Wins) return null; // Empate = sin apodo

    final bool isUser1 = (userId == user1Id);
    final bool user1IsLeading = user1Wins > user2Wins;

    if (isUser1) {
      return user1IsLeading ? 'DOMINANTE' : 'DOMINADO';
    } else {
      return user1IsLeading ? 'DOMINADO' : 'DOMINANTE';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Wins': user1Wins,
      'user2Wins': user2Wins,
      'lastCompetitiveMatchDate': lastCompetitiveMatchDate?.toIso8601String(),
    };
  }

  factory MatchHistoryModel.fromMap(Map<String, dynamic> map) {
    return MatchHistoryModel(
      user1Wins: map['user1Wins'] ?? 0,
      user2Wins: map['user2Wins'] ?? 0,
      lastCompetitiveMatchDate: DateTime.tryParse(map['lastCompetitiveMatchDate'] ?? ''),
    );
  }
}
