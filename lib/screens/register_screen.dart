import 'package:flutter/material.dart';
import '../models/user_account.dart';

class RegisterScreen extends StatefulWidget {
  final Function(UserAccount) onAccountCreated;

  const RegisterScreen({super.key, required this.onAccountCreated});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  Gender _selectedGender = Gender.male;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final int age = int.parse(_ageController.text);
      
      final newUser = UserAccount(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        gender: _selectedGender,
        pairingCode: UserAccount.generatePairingCode(),
      );

      // Pasa el usuario creado al flujo principal para continuar
      widget.onAccountCreated(newUser);
    }
  }

  void _signUpWithGoogle() {
    // Simulación de Google Auth
    final googleUser = UserAccount(
      uid: 'google_${DateTime.now().millisecondsSinceEpoch}',
      firstName: 'Usuario',
      lastName: 'Google',
      age: 20,
      gender: Gender.male,
      pairingCode: UserAccount.generatePairingCode(),
    );
    widget.onAccountCreated(googleUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Botón de Google Sign-In
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                ),
                icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                label: const Text('Continuar con Google', style: TextStyle(fontSize: 16)),
                onPressed: _signUpWithGoogle,
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('o registrarte con Email'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                validator: (val) => val == null || !val.contains('@') ? 'Ingresá un email válido' : null,
              ),
              const SizedBox(height: 12),
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
              const Text('Sexo (Color de fondo de tu avatar):'),
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
                child: const Text('Crear Cuenta y Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
