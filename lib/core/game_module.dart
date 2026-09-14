import 'package:flutter/material.dart';

enum GameCategory { classic, couples }

abstract class GameModule {
  String get id;
  String get title;
  String get description;
  IconData get icon;
  bool get isCoupleGame;
  bool get isCompetitive;

  String get name => title;
  bool get isAdultContent => false;
  GameCategory get category => isCoupleGame ? GameCategory.couples : GameCategory.classic;

  Widget buildGameScreen(BuildContext context);
  Widget buildScreen(BuildContext context) => buildGameScreen(context);
}
