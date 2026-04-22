import 'package:http/http.dart' as http;
import 'dart:convert';

class LanzadorService {
  static const String _ipEsp32 = 'http://192.168.112.1';

  static Future<bool> iniciarLanzamiento(String deporte, double potencia) async {
    try {
      final url = Uri.parse('$_ipEsp32/lanzar');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deporte': deporte, 
          'potencia': potencia.toInt(), 
        }),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> detenerMotores() async {
    try {
      final url = Uri.parse('$_ipEsp32/stop');
      final response = await http.post(url).timeout(const Duration(seconds: 2));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}