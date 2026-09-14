import 'package:flutter/material.dart';

abstract class GameModule {
  String get id;
  String get title;
  String get description;
  IconData get icon;
  bool get isCoupleGame;
  bool get isCompetitive; // Indicador de juego competitivo (ej: UNO, Truco)

  Widget buildGameScreen(BuildContext context);
}
