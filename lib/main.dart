import 'package:flutter/material.dart';
import 'models/user_account.dart';
import 'screens/register_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/couple_setup_screen.dart';

void main() {
  runApp(const ParejasApp());
}

class ParejasApp extends StatelessWidget {
  const ParejasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parejas App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      // Inicia directamente en el formulario de Registro (Paso 1)
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  // Simulador de estado para probar los flujos creados
  UserAccount? currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const RegisterScreen();
    }

    if (currentUser?.coupleId == null) {
      return PairingScreen(currentUser: currentUser!);
    }

    return const CoupleSetupScreen(
      user1Id: 'user_1',
      user2Id: 'user_2',
    );
  }
}
