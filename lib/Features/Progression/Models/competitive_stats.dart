class CompetitiveStats {
  final Map<String, int> winsByUser;
  final Map<String, int> lossesByUser;
  final DateTime? lastCompetitiveGameAt;

  CompetitiveStats({
    required this.winsByUser,
    required this.lossesByUser,
    this.lastCompetitiveGameAt,
  });

  bool get isInactiveForNickname {
    if (lastCompetitiveGameAt == null) return true;
    final duration = DateTime.now().difference(lastCompetitiveGameAt!);
    return duration.inDays >= 30;
  }

  String getNicknameForUser(String userUid, String partnerUid) {
    if (isInactiveForNickname) return "";

    final myWins = winsByUser[userUid] ?? 0;
    final partnerWins = winsByUser[partnerUid] ?? 0;

    if (myWins > partnerWins) {
      return "DOMINANTE";
    } else if (myWins < partnerWins) {
      return "DOMINADO";
    }
    return "";
  }

  void recordGameResult({required String winnerUid, required String loserUid}) {
    winsByUser[winnerUid] = (winsByUser[winnerUid] ?? 0) + 1;
    lossesByUser[loserUid] = (lossesByUser[loserUid] ?? 0) + 1;
  }
}
