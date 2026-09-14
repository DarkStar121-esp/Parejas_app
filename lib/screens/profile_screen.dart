import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/progression_model.dart';
import '../models/match_history_model.dart';

class ProfileScreen extends StatelessWidget {
  final UserAccount user;
  final UserAccount partner;
  final ProgressionModel progression;
  final MatchHistoryModel matchHistory;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.partner,
    required this.progression,
    required this.matchHistory,
  });

  Color _getBannerColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rosa': return Colors.pinkAccent;
      case 'azul': return Colors.blueAccent;
      case 'rojo': return Colors.redAccent;
      case 'morado': return Colors.purpleAccent;
      default: return Colors.blueGrey;
    }
  }

  Color _getAvatarBackgroundColor(Gender gender) {
    return gender == Gender.female ? Colors.pink.shade200 : Colors.blue.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final String? nickname = matchHistory.getNicknameForUser(user.uid, user.uid);
    final int nextLevelXp = ProgressionModel.xpForLevel(progression.level);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Pareja')),
      body: ListView(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: _getBannerColor(user.equippedBanner),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -30,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: _getAvatarBackgroundColor(user.gender),
                      child: Text(
                        user.equippedAvatar == 'default_silhouette' ? '👤' : '🦊',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Center(
            child: Column(
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (nickname != null) ...[
                  const SizedBox(height: 4),
                  Chip(
                    backgroundColor: nickname == 'DOMINANTE' ? Colors.amber : Colors.grey.shade400,
                    label: Text(
                      nickname,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nivel de Pareja: ${progression.level}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('🔥 Racha: ${progression.streakDays} días', style: const TextStyle(fontSize: 16, color: Colors.deepOrange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progression.currentXp / nextLevelXp,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.pinkAccent,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'XP: ${progression.currentXp} / $nextLevelXp',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estadísticas Competitivas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('${matchHistory.user1Wins}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                            const Text('Victorias'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('${matchHistory.user2Wins}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                            const Text('Derrotas'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
