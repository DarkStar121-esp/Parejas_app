import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';
import '../models/progression_model.dart';
import '../models/match_history_model.dart';
import 'profile_screen.dart';
import 'uno_game_screen.dart';
import 'words_game_screen.dart';

class HomeMenuScreen extends StatefulWidget {
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
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _savePairingLocally();
  }

  // Guardar la vinculacion para recordar la conexion al volver a abrir la app
  Future<void> _savePairingLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partnerId', widget.partner.uid);
    await prefs.setString('partnerName', widget.partner.displayName);
  }

  // Enviar invitacion de juego al otro dispositivo
  Future<void> _sendGameInvite(String gameTitle) async {
    final inviteId = '${widget.user.uid}_${widget.partner.uid}';
    await _firestore.collection('game_invitations').doc(inviteId).set({
      'senderId': widget.user.uid,
      'receiverId': widget.partner.uid,
      'senderName': widget.user.displayName,
      'gameTitle': gameTitle,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitación enviada a ${widget.partner.displayName}. Esperando respuesta...')),
      );
    }
  }

  void _navigateToGame(String gameTitle) {
    if (gameTitle == 'UNO Parejas') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UnoGameScreen(user: widget.user, partner: widget.partner)),
      );
    } else if (gameTitle == 'En Palabras') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WordsGameScreen(user: widget.user, partner: widget.partner)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviteId = '${widget.partner.uid}_${widget.user.uid}';

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
                    user: widget.user,
                    partner: widget.partner,
                    progression: widget.progression,
                    matchHistory: widget.matchHistory,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                          user: widget.user,
                          partner: widget.partner,
                          progression: widget.progression,
                          matchHistory: widget.matchHistory,
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
                              Text('Nivel de Pareja: ${widget.progression.level}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Conectado con: ${widget.partner.displayName} 💕'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Desafiar a tu Pareja:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildGameCard(context, 'UNO Parejas', Icons.style, Colors.red, () {
                        _sendGameInvite('UNO Parejas');
                      }),
                      _buildGameCard(context, 'En Palabras', Icons.font_download, Colors.blue, () {
                        _sendGameInvite('En Palabras');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Escuchar invitaciones entrantes enviadas por la pareja
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('game_invitations').doc(inviteId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data['status'] == 'pending') {
                  final String senderName = data['senderName'] ?? 'Tu pareja';
                  final String gameTitle = data['gameTitle'] ?? 'Juego';

                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sports_esports, size: 48, color: Colors.pink),
                              const SizedBox(height: 12),
                              Text(
                                '¡$senderName te invita a jugar!',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text('Juego: $gameTitle', style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    onPressed: () async {
                                      await _firestore.collection('game_invitations').doc(inviteId).update({'status': 'rejected'});
                                    },
                                    child: const Text('Rechazar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _firestore.collection('game_invitations').doc(inviteId).update({'status': 'accepted'});
                                      if (context.mounted) {
                                        _navigateToGame(gameTitle);
                                      }
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),

          // Escuchar cuando la pareja acepta nuestra invitacion para entrar al juego juntos
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('game_invitations').doc('${widget.user.uid}_${widget.partner.uid}').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data['status'] == 'accepted') {
                  final String gameTitle = data['gameTitle'] ?? 'Juego';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _firestore.collection('game_invitations').doc('${widget.user.uid}_${widget.partner.uid}').update({'status': 'in_game'});
                    _navigateToGame(gameTitle);
                  });
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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
