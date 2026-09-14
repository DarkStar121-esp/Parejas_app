import 'package:flutter/material.dart';

enum GameCategory { classic, couples }

abstract class GameModule {
  String get id => 'game_${title.toLowerCase().replaceAll(' ', '_')}';
  String get title => 'Juego';
  String get description => '';
  IconData get icon => Icons.casino;
  bool get isCoupleGame => false;
  bool get isCompetitive => false;

  // Propiedades de compatibilidad para HomeScreen y GameRegistry
  String get name => title;
  bool get isAdultContent => false;
  GameCategory get category => isCoupleGame ? GameCategory.couples : GameCategory.classic;

  Widget buildGameScreen(BuildContext context) => const Scaffold(
        body: Center(child: Text('Pantalla en construcción')),
      );

  Widget buildScreen(BuildContext context) => buildGameScreen(context);
}
