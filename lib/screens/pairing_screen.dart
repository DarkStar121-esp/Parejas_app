import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

class PairingScreen extends StatefulWidget {
  final UserAccount currentUser;
  final Function(UserAccount) onPairingCompleteWithPartner;

  const PairingScreen({
    super.key,
    required this.currentUser,
    required this.onPairingCompleteWithPartner,
  });

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _codeController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;

  Future<void> _linkWithPartnerCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 4) {
      setState(() => _errorMessage = 'Ingresa un código válido.');
      return;
    }

    if (code == widget.currentUser.pairingCode.toUpperCase()) {
      setState(() => _errorMessage = 'No puedes vincularte con tu propio código.');
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Buscar usuario con el código ingresado
      final querySnapshot = await firestore
          .collection('users')
          .where('pairingCode', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Código no encontrado. Verifica que tu pareja te lo haya pasado bien.';
          _isSearching = false;
        });
        return;
      }

      final partnerDoc = querySnapshot.docs.first;
      final partnerData = partnerDoc.data();
      final partnerUid = partnerDoc.id;

      // 2. Crear documento de pareja en la colección 'couples'
      final coupleDocRef = await firestore.collection('couples').add({
        'users': [widget.currentUser.uid, partnerUid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      final coupleId = coupleDocRef.id;

      # 3. Actualizar el coupleId en Firestore para ambos usuarios
      await firestore.collection('users').doc(widget.currentUser.uid).update({'coupleId': coupleId});
      await firestore.collection('users').doc(partnerUid).update({'coupleId': coupleId});

      // 4. Crear el objeto UserAccount de la pareja
      final partnerAccount = UserAccount(
        uid: partnerUid,
        firstName: partnerData['firstName'] ?? 'Pareja',
        lastName: partnerData['lastName'] ?? '',
        age: partnerData['age'] ?? 20,
        gender: (partnerData['gender'] == 'female') ? Gender.female : Gender.male,
        pairingCode: code,
        coupleId: coupleId,
      );

      if (mounted) {
        widget.onPairingCompleteWithPartner(partnerAccount);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de vinculación: $e';
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Pareja')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              color: Colors.pink.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Tu Código de Vinculación:', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.currentUser.pairingCode,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Compártelo con tu pareja para que lo ingrese en su teléfono.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('O ingresa el código de tu pareja:'),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Ej: AB12CD',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSearching ? null : _linkWithPartnerCode,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSearching
                  ? const CircularProgressIndicator()
                  : const Text('Vincular con Pareja', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
