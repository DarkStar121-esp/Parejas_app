import 'dart:math';

class SwapProposal {
  final String proposalId;
  final String fromUserId;
  final String toUserId;
  final String offeredAnimal;
  final String requestedAnimal;
  bool isAccepted;

  SwapProposal({
    required this.proposalId,
    required this.fromUserId,
    required this.toUserId,
    required this.offeredAnimal,
    required this.requestedAnimal,
    this.isAccepted = false,
  });
}

class AvatarService {
  // Catálogo completo de animales disponibles
  static const List<String> allAnimals = [
    'Zorro', 'Panda', 'Oso', 'Gato', 'Perro', 
    'Conejo', 'León', 'Tigre', 'Koala', 'Pingüino'
  ];

  // 5.1 Asignar animal random al subir de nivel (respetando unicidad en la pareja)
  static String? unlockRandomAnimalForUser({
    required List<String> userUnlocked,
    required List<String> partnerUnlocked,
  }) {
    // Excluir animales que ya tenga CUALQUIERA de los dos en la pareja
    final unavailable = {...userUnlocked, ...partnerUnlocked};
    final available = allAnimals.where((animal) => !unavailable.contains(animal)).toList();

    if (available.isEmpty) return null; // Ya tienen todos los animales desbloqueados

    final random = Random();
    return available[random.nextInt(available.length)];
  }

  // 5.1 Ejecutar el Intercambio 1-a-1 entre dos usuarios
  static bool executeSwap({
    required List<String> userAUnlocked,
    required List<String> userBUnlocked,
    required String animalFromA,
    required String animalFromB,
  }) {
    if (!userAUnlocked.contains(animalFromA) || !userBUnlocked.contains(animalFromB)) {
      return false; // Alguno no posee el animal ofrecido
    }

    // Intercambiar propiedad (mantiene la regla de unicidad intacta)
    userAUnlocked.remove(animalFromA);
    userAUnlocked.add(animalFromB);

    userBUnlocked.remove(animalFromB);
    userBUnlocked.add(animalFromA);

    return true;
  }
}
