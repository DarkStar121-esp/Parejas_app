import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class WifiPairingService {
  static const int _port = 45455; // Puerto arbitrario para el broadcast local
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;

  // 1. INICIAR TRANSMISIÓN (Dispositivo A anuncia su código en la red)
  Future<void> startBroadcasting({
    required String myName,
    required String myPairingCode,
  }) async {
    final info = NetworkInfo();
    final hostIp = await info.getWifiIP();
    if (hostIp == null) return;

    // Calcular dirección de broadcast (ej: 192.168.1.255)
    final subnet = hostIp.substring(0, hostIp.lastIndexOf('.'));
    final broadcastIp = '$subnet.255';

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket?.broadcastEnabled = true;

    final payload = jsonEncode({
      'name': myName,
      'code': myPairingCode,
    });

    // Enviar el anuncio cada 2 segundos
    _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final data = utf8.encode(payload);
      _socket?.send(data, InternetAddress(broadcastIp), _port);
    });
  }

  // 2. INICIAR ESCUCHA (Dispositivo B busca parejas en la misma red)
  Future<void> startListening({
    required Function(String name, String code) onPartnerDiscovered,
  }) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
    _socket?.broadcastEnabled = true;

    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket?.receive();
        if (dg != null) {
          final message = utf8.decode(dg.data);
          try {
            final data = jsonDecode(message);
            final String name = data['name'];
            final String code = data['code'];
            
            // Notificar a la interfaz de usuario que se encontró a alguien
            onPartnerDiscovered(name, code);
          } catch (e) {
            // Ignorar paquetes malformados
          }
        }
      }
    });
  }

  // Detener servicios de red al salir de la pantalla
  void stop() {
    _broadcastTimer?.cancel();
    _socket?.close();
  }
}
