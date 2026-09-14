import 'package:flutter/widgets.dart';
import '../../../core/game_module.dart';
import '../../../core/coming_soon_screen.dart';

class ChinchonModule extends GameModule {
  @override
  String get id => 'chinchon';
  @override
  String get name => 'Chinchón';
  @override
  String get description => 'Formá escaleras y grupos, el que menos puntos suma gana.';
  @override
  GameCategory get category => GameCategory.classic;
  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 4;

  @override
  Widget buildScreen(BuildContext context) => const ComingSoonScreen(
        gameName: 'Chinchón',
        description: 'Motor de reglas pendiente — mismo patrón que UNO (ver uno_engine.dart).',
      );
}
