import 'package:flutter/material.dart';
import 'models/user_account.dart';
import 'screens/register_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/couple_setup_screen.dart';
import 'screens/home_menu_screen.dart';

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
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

enum AppStep { register, pairing, coupleSetup, home }

class _MainNavigationHubState extends State<MainNavigationHub> {
  AppStep _currentStep = AppStep.register;
  UserAccount? _currentUser;

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case AppStep.register:
        return RegisterScreen(
          onAccountCreated: (user) {
            setState(() {
              _currentUser = user;
              _currentStep = AppStep.pairing;
            });
          },
        );

      case AppStep.pairing:
        return PairingScreen(
          currentUser: _currentUser!,
        );

      case AppStep.coupleSetup:
        return CoupleSetupScreen(
          user1Id: _currentUser?.uid ?? '1',
          user2Id: 'partner_id',
        );

      case AppStep.home:
        return const HomeMenuScreen();
    }
  }
}
