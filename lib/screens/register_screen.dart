import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? fbUser = userCredential.user;

      if (fbUser != null) {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(fbUser.uid);
        final userDoc = await userDocRef.get();

        UserAccount userAccount;

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          userAccount = UserAccount(
            uid: fbUser.uid,
            firstName: data['firstName'] ?? 'Usuario',
            lastName: data['lastName'] ?? '',
            age: data['age'] ?? 20,
            gender: (data['gender'] == 'female') ? Gender.female : Gender.male,
            pairingCode: data['pairingCode'] ?? UserAccount.generatePairingCode(),
            coupleId: data['coupleId'],
          );
        } else {
          final nameParts = (fbUser.displayName ?? 'Usuario Google').split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : 'Usuario';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          final pairingCode = UserAccount.generatePairingCode();

          userAccount = UserAccount(
            uid: fbUser.uid,
            firstName: firstName,
            lastName: lastName,
            age: 20,
            gender: Gender.male,
            pairingCode: pairingCode,
          );

          await userDocRef.set({
            'uid': fbUser.uid,
            'email': fbUser.email,
            'firstName': firstName,
            'lastName': lastName,
            'age': 20,
            'gender': 'male',
            'pairingCode': pairingCode,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (mounted) {
          widget.onAccountCreated(userAccount);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en inicio de sesión con Google: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
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
                          child: Text('o regístrate con Nombre'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (val) => val == null || val.isEmpty ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (val) => val == null || val.isEmpty ? 'Ingresa tu apellido' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
                          final pairingCode = UserAccount.generatePairingCode();
                          final userAccount = UserAccount(
                            uid: uid,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            age: 20,
                            gender: Gender.male,
                            pairingCode: pairingCode,
                          );

                          await FirebaseFirestore.instance.collection('users').doc(uid).set({
                            'uid': uid,
                            'firstName': _firstNameController.text,
                            'lastName': _lastNameController.text,
                            'age': 20,
                            'gender': 'male',
                            'pairingCode': pairingCode,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          widget.onAccountCreated(userAccount);
                        }
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
