import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/pairing_service.dart';
import 'pairing_dialog.dart';

class PairingScreen extends StatefulWidget {
  final UserAccount currentUser;
  final Function(UserAccount partner) onPairingCompleteWithPartner;

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

  void _searchAndPair(String code) async {
    if (code.trim().isEmpty) return;
    setState(() => _isSearching = true);
    
    final partner = await PairingService.findUserByCode(code.trim());
    setState(() => _isSearching = false);

    if (partner != null && mounted) {
      _showConfirmationDialog(partner);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el código de tu pareja o las cuentas no coinciden.')),
      );
    }
  }

  void _showConfirmationDialog(UserAccount partner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PairingConfirmationDialog(
        userA: widget.currentUser,
        userB: partner,
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () {
          Navigator.pop(ctx);
          widget.onPairingCompleteWithPartner(partner);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conectar Cuentas de Pareja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('Tu Código de Emparejamiento'),
                subtitle: Text(
                  widget.currentUser.pairingCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Ingresá el código del celular de tu pareja:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 7K2P9X',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching ? null : () => _searchAndPair(_codeController.text),
                  child: _isSearching 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text('Vincular'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
