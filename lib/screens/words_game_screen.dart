import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

class WordsGameScreen extends StatefulWidget {
  final UserAccount user;
  final UserAccount partner;

  const WordsGameScreen({super.key, required this.user, required this.partner});

  @override
  State<WordsGameScreen> createState() => _WordsGameScreenState();
}

class _WordsGameScreenState extends State<WordsGameScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _wordController = TextEditingController();

  String get matchId => widget.user.uid.compareTo(widget.partner.uid) < 0
      ? '${widget.user.uid}_${widget.partner.uid}'
      : '${widget.partner.uid}_${widget.user.uid}';

  @override
  void initState() {
    super.initState();
    _initMatch();
  }

  Future<void> _initMatch() async {
    final docRef = _firestore.collection('words_matches').doc(matchId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'currentTurn': widget.user.uid,
        'wordsList': <String>['AMOR'],
        'lastWord': 'AMOR',
      });
    }
  }

  Future<void> _submitWord(String currentTurn, List<dynamic> currentWords) async {
    final newWord = _wordController.text.trim().toUpperCase();
    if (newWord.isEmpty || currentTurn != widget.user.uid) return;

    final updatedList = List<String>.from(currentWords)..add(newWord);
    await _firestore.collection('words_matches').doc(matchId).update({
      'currentTurn': widget.partner.uid,
      'wordsList': updatedList,
      'lastWord': newWord,
    });
    _wordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En Palabras 1v1 (${widget.partner.displayName})'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('words_matches').doc(matchId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String currentTurn = data['currentTurn'] ?? '';
          final List<dynamic> wordsList = data['wordsList'] ?? [];
          final bool isMyTurn = currentTurn == widget.user.uid;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  color: isMyTurn ? Colors.blue.shade100 : Colors.grey.shade200,
                  child: ListTile(
                    title: Text(
                      isMyTurn ? '¡Es tu turno de enviar una palabra!' : 'Esperando palabra de ${widget.partner.displayName}...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: wordsList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(wordsList[index].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _wordController,
                        enabled: isMyTurn,
                        decoration: const InputDecoration(
                          hintText: 'Escribí tu palabra...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isMyTurn ? () => _submitWord(currentTurn, wordsList) : null,
                      child: const Text('Enviar'),
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
