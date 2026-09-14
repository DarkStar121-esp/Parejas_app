import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

class UnoGameScreen extends StatefulWidget {
  final UserAccount user;
  final UserAccount partner;

  const UnoGameScreen({super.key, required this.user, required this.partner});

  @override
  State<UnoGameScreen> createState() => _UnoGameScreenState();
}

class _UnoGameScreenState extends State<UnoGameScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get matchId => widget.user.uid.compareTo(widget.partner.uid) < 0
      ? '${widget.user.uid}_${widget.partner.uid}'
      : '${widget.partner.uid}_${widget.user.uid}';

  @override
  void initState() {
    super.initState();
    _initOrGetGame();
  }

  Future<void> _initOrGetGame() async {
    final docRef = _firestore.collection('uno_matches').doc(matchId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'currentTurn': widget.user.uid,
        'topCard': 'Rojo 7',
        'userCardsCount': {
          widget.user.uid: 7,
          widget.partner.uid: 7,
        },
        'status': 'playing',
        'lastMove': 'Juego iniciado',
      });
    }
  }

  Future<void> _playTurn(String currentTurn, String card) async {
    if (currentTurn != widget.user.uid) return;
    final nextTurn = widget.partner.uid;
    await _firestore.collection('uno_matches').doc(matchId).update({
      'currentTurn': nextTurn,
      'topCard': card,
      'lastMove': '${widget.user.displayName} jugó $card',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UNO Parejas (${widget.partner.displayName})'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('uno_matches').doc(matchId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String currentTurn = data['currentTurn'] ?? '';
          final String topCard = data['topCard'] ?? 'Carta';
          final String lastMove = data['lastMove'] ?? '';
          final bool isMyTurn = currentTurn == widget.user.uid;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  color: isMyTurn ? Colors.green.shade100 : Colors.amber.shade100,
                  child: ListTile(
                    title: Text(
                      isMyTurn ? '¡Es TU Turno!' : 'Esperando turno de ${widget.partner.displayName}...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('Última jugada: $lastMove'),
                  ),
                ),
                const Spacer(),
                const Text('Mesa de Juego', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  width: 120,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      topCard,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Tus Cartas disponibles:'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isMyTurn ? () => _playTurn(currentTurn, 'Azul 4') : null,
                      child: const Text('Azul 4'),
                    ),
                    ElevatedButton(
                      onPressed: isMyTurn ? () => _playTurn(currentTurn, 'Verde +2') : null,
                      child: const Text('Verde +2'),
                    ),
                    ElevatedButton(
                      onPressed: isMyTurn ? () => _playTurn(currentTurn, 'Amarillo 9') : null,
                      child: const Text('Amarillo 9'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
