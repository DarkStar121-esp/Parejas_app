import 'package:flutter/material.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parejas App - Menú Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.pink.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.favorite, color: Colors.red)),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nivel de Pareja: 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Racha: 1 día 🔥'),
                      ],
                    ),
                  ],
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
