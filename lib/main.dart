import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/user_account.dart';
import 'models/progression_model.dart';
import 'models/match_history_model.dart';
import 'screens/register_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/couple_setup_screen.dart';
import 'screens/home_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
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
  bool _isLoadingSession = true;

  final ProgressionModel _progression = ProgressionModel(level: 1, currentXp: 0, streakDays: 0);
  final MatchHistoryModel _matchHistory = MatchHistoryModel(user1Wins: 0, user2Wins: 0);

  bool get _isPairedSuccessfully => _currentUser != null && _partnerUser != null;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          final userAcc = UserAccount(
            uid: fbUser.uid,
            firstName: data['firstName'] ?? 'Usuario',
            lastName: data['lastName'] ?? '',
            age: data['age'] ?? 20,
            gender: (data['gender'] == 'female') ? Gender.female : Gender.male,
            pairingCode: data['pairingCode'] ?? UserAccount.generatePairingCode(),
            coupleId: data['coupleId'],
          );

          _currentUser = userAcc;

          if (userAcc.coupleId != null && userAcc.coupleId!.isNotEmpty) {
            final coupleDoc = await FirebaseFirestore.instance
                .collection('couples')
                .doc(userAcc.coupleId)
                .get();

            if (coupleDoc.exists && coupleDoc.data() != null) {
              final coupleData = coupleDoc.data()!;
              final List<dynamic> users = coupleData['users'] ?? [];
              final partnerId = users.firstWhere((id) => id != userAcc.uid, orElse: () => null);

              if (partnerId != null) {
                final partnerDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(partnerId)
                    .get();

                if (partnerDoc.exists && partnerDoc.data() != null) {
                  final pData = partnerDoc.data()!;
                  _partnerUser = UserAccount(
                    uid: partnerId,
                    firstName: pData['firstName'] ?? 'Pareja',
                    lastName: pData['lastName'] ?? '',
                    age: pData['age'] ?? 20,
                    gender: (pData['gender'] == 'female') ? Gender.female : Gender.male,
                    pairingCode: pData['pairingCode'] ?? '',
                    coupleId: userAcc.coupleId,
                  );
                  _currentStep = AppStep.home;
                } else {
                  _currentStep = AppStep.pairing;
                }
              } else {
                _currentStep = AppStep.pairing;
              }
            } else {
              _currentStep = AppStep.pairing;
            }
          } else {
            _currentStep = AppStep.pairing;
          }
        }
      } catch (e) {
        debugPrint('Error al verificar sesión existente: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoadingSession = false);
    }
  }

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
    if (_isLoadingSession) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando sesión...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

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
              child: Text('Debes vincular tu cuenta con la de tu pareja para continuar.'),
            ),
          );
        }
        return CoupleSetupScreen(
          user1Id: _currentUser!.uid,
          user2Id: _partnerUser!.uid,
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
