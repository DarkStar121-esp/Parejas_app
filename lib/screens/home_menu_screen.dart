import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/progression_model.dart';
import '../models/match_history_model.dart';
import 'profile_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para pruebas en UI
    final dummyUser = UserAccount(
      uid: 'u1',
      firstName: 'Santiago',
      lastName: 'Villarruel',
      age: 24,
      gender: Gender.male,
      pairingCode: 'ABC123',
      equippedBanner: 'azul',
    );

    final dummyPartner = UserAccount(
      uid: 'u2',
      firstName: 'Pareja',
      lastName: 'Ejemplo',
      age: 23,
      gender: Gender.female,
      pairingCode: 'XYZ789',
    );

    final dummyProgression = ProgressionModel(level: 3, currentXp: 140, streakDays: 5);
    final dummyMatchHistory = MatchHistoryModel(user1Wins: 8, user2Wins: 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parejas App - Juegos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: dummyUser,
                    partner: dummyPartner,
                    progression: dummyProgression,
                    matchHistory: dummyMatchHistory,
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
                      user: dummyUser,
                      partner: dummyPartner,
                      progression: dummyProgression,
                      matchHistory: dummyMatchHistory,
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
                          Text('Nivel de Pareja: ${dummyProgression.level}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Racha: ${dummyProgression.streakDays} días 🔥 | Toca para ver Perfil'),
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
                  _buildGameCard(context, 'Verdad o Reto', Icons.psychology, Colors.purple),
                  _buildGameCard(context, '¿Quién es más...?', Icons.people, Colors.orange),
                  _buildGameCard(context, 'Preguntados Pareja', Icons.quiz, Colors.blue),
                  _buildGameCard(context, 'Desafío 1v1', Icons.sports_esports, Colors.red),
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
            SnackBar(content: Text('Iniciando $title...')),
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
