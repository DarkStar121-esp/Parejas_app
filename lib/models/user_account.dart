import 'dart:math';

enum Gender { male, female }

class UserAccount {
  final String uid;
  final String firstName;
  final String lastName;
  final int age;
  final Gender gender;
  final String pairingCode;
  final String? coupleId;

  // Personalización del perfil
  final String equippedAvatar;
  final List<String> unlockedAvatars;
  final String equippedFont;
  final String equippedBanner;

  UserAccount({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.pairingCode,
    this.coupleId,
    this.equippedAvatar = 'default_silhouette',
    List<String>? unlockedAvatars,
    this.equippedFont = 'system',
    this.equippedBanner = 'white',
  }) : unlockedAvatars = unlockedAvatars ?? ['default_silhouette'];

  // Getter agregado para solucionar el error de compilación
  String get displayName => '$firstName $lastName';

  // Validación de edad mínima (18 años)
  static bool isAdult(int age) => age >= 18;

  // Generador del pairing code corto (6 caracteres)
  static String generatePairingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender.name,
      'pairingCode': pairingCode,
      'coupleId': coupleId,
      'equippedAvatar': equippedAvatar,
      'unlockedAvatars': unlockedAvatars,
      'equippedFont': equippedFont,
      'equippedBanner': equippedBanner,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] == 'female' ? Gender.female : Gender.male,
      pairingCode: map['pairingCode'] ?? '',
      coupleId: map['coupleId'],
      equippedAvatar: map['equippedAvatar'] ?? 'default_silhouette',
      unlockedAvatars: List<String>.from(map['unlockedAvatars'] ?? ['default_silhouette']),
      equippedFont: map['equippedFont'] ?? 'system',
      equippedBanner: map['equippedBanner'] ?? 'white',
    );
  }
}
