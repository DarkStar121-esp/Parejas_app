import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/progression_model.dart';
import '../models/match_history_model.dart';
import 'profile_screen.dart';
import 'uno_game_screen.dart';
import 'words_game_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  final UserAccount user;
  final UserAccount partner;
  final ProgressionModel progression;
  final MatchHistoryModel matchHistory;

  const HomeMenuScreen({
    super.key,
    required this.user,
    required this.partner,
    required this.progression,
    required this.matchHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parejas App - Menú Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: user,
                    partner: partner,
                    progression: progression,
                    matchHistory: matchHistory,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      user: user,
                      partner: partner,
                      progression: progression,
                      matchHistory: matchHistory,
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.pink.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.pink,
                        child: Icon(Icons.favorite, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nivel de Pareja: ${progression.level}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Racha: ${progression.streakDays} días 🔥 | Ver Perfil'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Seleccioná un Juego Multiplayer:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildGameCard(context, 'UNO Parejas', Icons.style, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnoGameScreen(user: user, partner: partner),
                      ),
                    );
                  }),
                  _buildGameCard(context, 'En Palabras', Icons.font_download, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordsGameScreen(user: user, partner: partner),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
