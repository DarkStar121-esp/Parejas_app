import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
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
  FirebaseFirestore get _firestore {
    if (Firebase.apps.isEmpty) {
      Firebase.initializeApp();
    }
    return FirebaseFirestore.instance;
  }

  @override
  void initState() {
    super.initState();
    _savePairingLocally();
  }

  Future<void> _savePairingLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('partnerId', widget.partner.uid);
      await prefs.setString('partnerName', widget.partner.displayName);
    } catch (e) {
      debugPrint("Error saving pairing locally: $e");
    }
  }

  Future<void> _sendGameInvite(String gameTitle) async {
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar invitación: $e')),
        );
      }
    }
  }

  void _navigateToGame(String gameTitle) {
    if (gameTitle == 'UNO Parejas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnoGameScreen(user: widget.user, partner: widget.partner),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordsGameScreen(user: widget.user, partner: widget.partner),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parejas: ${widget.user.displayName} & ${widget.partner.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: widget.user,
                    partner: widget.partner,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Nivel ${widget.progression.level} - XP: ${widget.progression.currentXp}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Racha actual: ${widget.progression.streakDays} días'),
                    const SizedBox(height: 8),
                    Text('Victorias: ${widget.matchHistory.user1Wins} vs ${widget.matchHistory.user2Wins}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Juegos Disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _sendGameInvite('UNO Parejas');
                _navigateToGame('UNO Parejas');
              },
              icon: const Icon(Icons.gamepad),
              label: const Text('Jugar UNO Parejas'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _sendGameInvite('Palabras Cruzadas');
                _navigateToGame('Palabras Cruzadas');
              },
              icon: const Icon(Icons.abc),
              label: const Text('Jugar Palabras Cruzadas'),
            ),
          ],
        ),
      ),
    );
  }
}
