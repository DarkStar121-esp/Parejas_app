import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/pairing_service.dart';
import 'pairing_dialog.dart';

class PairingScreen extends StatefulWidget {
  final UserAccount currentUser;

  const PairingScreen({super.key, required this.currentUser});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _codeController = TextEditingController();
  bool _isSearching = false;
  UserAccount? _discoveredWifiUser;

  @override
  void initState() {
    super.initState();
    _listenWifiPeers();
  }

  void _listenWifiPeers() {
    PairingService.discoverLocalWifiPeers().listen((user) {
      if (mounted) {
        setState(() => _discoveredWifiUser = user);
      }
    });
  }

  void _searchAndPair(String code) async {
    setState(() => _isSearching = true);
    final partner = await PairingService.findUserByCode(code);
    setState(() => _isSearching = false);

    if (partner != null && mounted) {
      _showConfirmationDialog(partner);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Emparejados con éxito con ${partner.firstName}!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conectar con tu Pareja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tu Código de Emparejamiento'),
                subtitle: Text(
                  widget.currentUser.pairingCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('1. Ingresar código de tu pareja:'),
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
                  onPressed: _isSearching ? null : () => _searchAndPair(_codeController.text.trim()),
                  child: _isSearching ? const CircularProgressIndicator() : const Text('Conectar'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('2. Mismo WiFi (Descubrimiento automático):'),
            const SizedBox(height: 8),
            if (_discoveredWifiUser != null)
              Card(
                color: Colors.pink.shade50,
                child: ListTile(
                  leading: const Icon(Icons.wifi, color: Colors.pink),
                  title: Text('¿Te querés conectar con ${_discoveredWifiUser!.firstName}?'),
                  subtitle: const Text('Detectado en la misma red WiFi'),
                  trailing: ElevatedButton(
                    onPressed: () => _showConfirmationDialog(_discoveredWifiUser!),
                    child: const Text('Conectar'),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Buscando dispositivos en la misma red...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
