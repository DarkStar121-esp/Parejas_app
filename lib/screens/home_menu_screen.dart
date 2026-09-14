import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/progression_model.dart';
import '../models/match_history_model.dart';
import 'profile_screen.dart';

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
        title: const Text('Parejas App - Menú de Juegos'),
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
            const Text('Seleccioná un Juego:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildGameCard(context, 'UNO Parejas', Icons.style, Colors.red),
                  _buildGameCard(context, 'En Palabras', Icons.font_download, Colors.blue),
                  _buildGameCard(context, 'Verdad o Reto', Icons.psychology, Colors.purple),
                  _buildGameCard(context, 'Desafío 1v1', Icons.sports_esports, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abriendo $title...')),
          );
        },
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
