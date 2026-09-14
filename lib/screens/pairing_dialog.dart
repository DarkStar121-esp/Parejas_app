import 'package:flutter/material.dart';
import '../models/user_account.dart';

class PairingConfirmationDialog extends StatelessWidget {
  final UserAccount userA;
  final UserAccount userB;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PairingConfirmationDialog({
    super.key,
    required this.userA,
    required this.userB,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Conexión Permanente'),
          ],
        ),
        content: Text(
          '⚠️ Esta conexión es permanente.\n\n'
          'Una vez conectadas, las cuentas de ${userA.firstName} y ${userB.firstName} no se pueden desvincular desde la app. '
          'Todo el progreso (nivel, personalización, racha) es compartido de acá en adelante.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: onConfirm,
            child: const Text('Conectar para siempre', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
