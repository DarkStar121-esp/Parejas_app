import 'package:flutter/material.dart';
import '../models/user_account.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final int age = int.parse(_ageController.text);
      
      final newUser = UserAccount(
        uid: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        gender: _selectedGender,
        pairingCode: UserAccount.generatePairingCode(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta creada para ${newUser.firstName}. Código: ${newUser.pairingCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta Individual')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (val) => val == null || val.isEmpty ? 'Ingresá tu nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (val) => val == null || val.isEmpty ? 'Ingresá tu apellido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresá tu edad';
                  final age = int.tryParse(val);
                  if (age == null) return 'Ingresá un número válido';
                  if (!UserAccount.isAdult(age)) return 'Debes ser mayor de 18 años para registrarte';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Sexo (determina el color de fondo del avatar):'),
              RadioListTile<Gender>(
                title: const Text('Hombre (Fondo Azul)'),
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              RadioListTile<Gender>(
                title: const Text('Mujer (Fondo Rosa)'),
                value: Gender.female,
                groupValue: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Crear Cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
