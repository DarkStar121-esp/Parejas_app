import 'package:flutter/material.dart';

class IrreversiblePairingDialog extends StatelessWidget {
  final String partnerName;
  final VoidCallback onConfirm;

  const IrreversiblePairingDialog({
    Key? key,
    required this.partnerName,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text('Conexión Permanente'),
        ],
      ),
      content: Text(
        '⚠️ Esta conexión es permanente.\n\n'
        'Una vez conectadas, tu cuenta y la de $partnerName no se pueden desvincular desde la app. '
        'Todo el progreso (nivel, personalización, racha) será compartido de acá en adelante.',
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: const Text('Conectar para siempre'),
        ),
      ],
    );
  }
}
