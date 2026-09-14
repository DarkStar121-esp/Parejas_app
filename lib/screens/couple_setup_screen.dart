import 'package:flutter/material.dart';
import '../models/couple_model.dart';

class CoupleSetupScreen extends StatefulWidget {
  final String user1Id;
  final String user2Id;
  final VoidCallback onSetupComplete;

  const CoupleSetupScreen({
    super.key,
    required this.user1Id,
    required this.user2Id,
    required this.onSetupComplete,
  });

  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen> {
  RelationshipType _selectedType = RelationshipType.novios;
  DateTime _startDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  void _createCouple() {
    final couple = CoupleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user1Id: widget.user1Id,
      user2Id: widget.user2Id,
      relationshipType: _selectedType,
      relationshipStartDate: _startDate,
      pairedAt: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Pareja creada! Llevan: ${couple.timeTogetherFormatted}')),
    );

    // Avanza al menú principal de juegos
    widget.onSetupComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información de la Pareja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionen el tipo de relación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<RelationshipType>(
              value: _selectedType,
              isExpanded: true,
              items: RelationshipType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Cuándo empezó la relación?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Cambiar Fecha'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createCouple,
                child: const Text('Guardar y Entrar a los Juegos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
