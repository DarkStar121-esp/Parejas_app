import 'package:flutter/material.dart';
import 'package:parejas_app/features/progression/widgets/irreversible_pairing_dialog.dart';
import 'package:parejas_app/features/progression/services/wifi_pairing_service.dart';

class PairingScreen extends StatefulWidget {
  final String currentUserName;
  final String currentUserPairingCode;

  const PairingScreen({
    Key? key,
    required this.currentUserName,
    required this.currentUserPairingCode,
  }) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _codeController = TextEditingController();
  final WifiPairingService _wifiService = WifiPairingService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 1. Iniciar transmisión UDP en segundo plano (anuncia nuestro pairingCode en la red local)
    _wifiService.startBroadcasting(
      myName: widget.currentUserName,
      myPairingCode: widget.currentUserPairingCode,
    );

    // 2. Escuchar la red local para detectar a la pareja automáticamente
    _wifiService.startListening(
      onPartnerDiscovered: (nombreDetectado, codigoDetectado) {
        _mostrarSugerenciaWifi(nombreDetectado, codigoDetectado);
      },
    );
  }

  // Despliega un aviso flotante cuando descubre a alguien en el mismo WiFi
  void _mostrarSugerenciaWifi(String nombre, String codigo) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('¿Te querés conectar con $nombre en esta red WiFi?'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              _codeController.text = codigo; // Autocompleta el código encontrado
              _intentarEmparejamiento(nombreParejaDetectada: nombre); // Ejecuta flujo con diálogo irreversible
            },
            child: const Text('CONECTAR'),
          ),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('IGNORAR'),
          ),
        ],
      ),
    );
  }

  // Lógica principal de emparejamiento (Manual por código o por atajo de WiFi)
  Future<void> _intentarEmparejamiento({String? nombreParejaDetectada}) async {
    final codigoIngresado = _codeController.text.trim().toUpperCase();

    if (codigoIngresado.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener 6 caracteres.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Nombre de la pareja (por WiFi ya lo tenemos, por código se consulta al backend)
    String nombrePareja = nombreParejaDetectada ?? "Tu Pareja";

    setState(() => _isLoading = false);

    // INVOCACIÓN DEL DIÁLOGO BLOQUEANTE E IRREVERSIBLE (Exigido en sección 3.2 del PDF)
    final bool? realizoConexion = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Bloqueante: no permite ignorarlo tocando afuera
      builder: (BuildContext context) {
        return IrreversiblePairingDialog(
          partnerName: nombrePareja,
          onConfirm: () {
            // Confirmación desde el diálogo
          },
        );
      },
    );

    // Si la persona presiona "Conectar para siempre"
    if (realizoConexion == true) {
      _confirmarConexionEnBackend(codigoIngresado);
    }
  }

  void _confirmarConexionEnBackend(String codigo) {
    // Acá se realiza la escritura final en la base de datos (creación del objeto Couple)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Cuentas conectadas exitosamente para siempre! ❤️')),
    );
  }

  @override
  void dispose() {
    _wifiService.stop(); // Cancela la escucha y transmisión de sockets al salir
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Pareja')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresá el código de 6 caracteres de tu pareja o esperá a que se detecten automáticamente en la misma red WiFi:',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'EJ: 7K2P9X',
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _intentarEmparejamiento(),
                    child: const Text('Conectar cuentas', style: TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }
}
