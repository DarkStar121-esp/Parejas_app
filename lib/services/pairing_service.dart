import 'dart:async';
import '../models/user_account.dart';

class PairingRequest {
  final String requestId;
  final UserAccount fromUser;
  final String targetCode;
  final DateTime createdAt;

  PairingRequest({
    required this.requestId,
    required this.fromUser,
    required this.targetCode,
    required this.createdAt,
  });
}

class PairingService {
  // Simulación de búsqueda por código
  static Future<UserAccount?> findUserByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Retorna usuario ficticio encontrado por el código para pruebas
    return UserAccount(
      uid: 'partner_999',
      firstName: 'Pareja',
      lastName: 'Ejemplo',
      age: 22,
      gender: Gender.female,
      pairingCode: code,
    );
  }

  // Simulación de descubrimiento por Broadcast en WiFi local
  static Stream<UserAccount> discoverLocalWifiPeers() async* {
    await Future.delayed(const Duration(seconds: 2));
    yield UserAccount(
      uid: 'wifi_peer_123',
      firstName: 'Pareja en WiFi',
      lastName: 'Cercana',
      age: 24,
      gender: Gender.female,
      pairingCode: 'WIFI88',
    );
  }
}
