enum Gender { male, female }

class UserAccount {
  final String uid;
  final String firstName;
  final String lastName;
  final int age;
  final Gender gender;
  final String pairingCode;
  final String? coupleId;

  // Personalización
  String equippedAvatar; // Nombre del animal o 'default_silhouette'
  String equippedFont;   // Nombre de la tipografía
  String equippedBanner; // ID/Color del banner

  List<String> unlockedAnimals;

  UserAccount({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.pairingCode,
    this.coupleId,
    required this.equippedAvatar,
    required this.equippedFont,
    required this.equippedBanner,
    required this.unlockedAnimals,
  });

  String get defaultBackgroundColorHex =>
      gender == Gender.female ? '#FFC0CB' : '#87CEEB';

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
      'equippedFont': equippedFont,
      'equippedBanner': equippedBanner,
      'unlockedAnimals': unlockedAnimals,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      age: map['age'] ?? 18,
      gender: map['gender'] == 'female' ? Gender.female : Gender.male,
      pairingCode: map['pairingCode'] ?? '',
      coupleId: map['coupleId'],
      equippedAvatar: map['equippedAvatar'] ?? 'default_silhouette',
      equippedFont: map['equippedFont'] ?? 'System',
      equippedBanner: map['equippedBanner'] ?? '#FFFFFF',
      unlockedAnimals: List<String>.from(map['unlockedAnimals'] ?? []),
    );
  }
}
