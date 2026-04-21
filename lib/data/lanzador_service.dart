import 'package:http/http.dart' as http;
import 'dart:convert';

class LanzadorService {
  // La IP de tu ESP32. Al estar en la misma red Wi-Fi, la respuesta será instantánea.
  static const String _ipEsp32 = 'http://192.168.112.1';

  // --- 1. COMANDO DE LANZAMIENTO ---
  static Future<bool> iniciarLanzamiento(String deporte, double potencia) async {
    try {
      final url = Uri.parse('$_ipEsp32/lanzar');
      
      // Enviamos un paquete JSON con las instrucciones exactas para los motores
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deporte': deporte, // 'Fútbol' o 'Vóley'
          'potencia': potencia.toInt(), // Nivel del 1 al 10
        }),
      ).timeout(const Duration(seconds: 3)); // Si en 3 segundos no responde, falla

      return response.statusCode == 200;
    } catch (e) {
      // Si el ESP32 está apagado o el celular no está en su red Wi-Fi, caerá aquí
      return false;
    }
  }

  // --- 2. PARADA DE EMERGENCIA (CRÍTICO) ---
  static Future<bool> detenerMotores() async {
    try {
      final url = Uri.parse('$_ipEsp32/stop');
      // Un simple POST vacío para cortar la energía inmediatamente
      final response = await http.post(url).timeout(const Duration(seconds: 2));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}