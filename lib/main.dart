import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/user_account.dart';
import 'models/progression_model.dart';
import 'models/match_history_model.dart';
import 'screens/register_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/couple_setup_screen.dart';
import 'screens/home_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("CRITICAL FIREBASE ERROR: $e");
  }
  runApp(const ParejasApp());
}

class ParejasApp extends StatelessWidget {
  const ParejasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parejas App',
      debugShowCheckedModeBanner: false,
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
  UserAccount? _partnerUser;

  final ProgressionModel _progression = ProgressionModel(level: 1, currentXp: 0, streakDays: 0);
  final MatchHistoryModel _matchHistory = MatchHistoryModel(user1Wins: 0, user2Wins: 0);

  bool get _isPairedSuccessfully => _currentUser != null && _partnerUser != null;

  void _onBackPressed() {
    setState(() {
      if (_currentStep == AppStep.home) {
        _currentStep = AppStep.coupleSetup;
      } else if (_currentStep == AppStep.coupleSetup) {
        _currentStep = AppStep.pairing;
      } else if (_currentStep == AppStep.pairing) {
        _currentStep = AppStep.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == AppStep.register,
      onPopInvoked: (didPop) {
        if (!didPop && _currentStep != AppStep.register) {
          _onBackPressed();
        }
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
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
          onPairingCompleteWithPartner: (partner) {
            setState(() {
              _partnerUser = partner;
              _currentStep = AppStep.coupleSetup;
            });
          },
        );

      case AppStep.coupleSetup:
        if (!_isPairedSuccessfully) {
          return const Scaffold(
            body: Center(
              child: Text('Debes vincular tu cuenta con la de tu pareja en tiempo real para continuar.'),
            ),
          );
        }
        return CoupleSetupScreen(
          userId1: _currentUser!.uid,
          userId2: _partnerUser!.uid,
          onSetupComplete: () {
            setState(() {
              _currentStep = AppStep.home;
            });
          },
        );

      case AppStep.home:
        if (!_isPairedSuccessfully) {
          return const Scaffold(
            body: Center(
              child: Text('Acceso denegado: No existe una vinculación activa entre ambos dispositivos.'),
            ),
          );
        }
        return HomeMenuScreen(
          user: _currentUser!,
          partner: _partnerUser!,
          progression: _progression,
          matchHistory: _matchHistory,
        );
    }
  }
}
