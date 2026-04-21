import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/alumno_model.dart';
import '../domain/seccion_model.dart'; // Importación obligatoria para reconocer 'Seccion'

class ExportService {
  // El nombre y los parámetros ahora coinciden exactamente con lo que pide alumnos_screen.dart
  static Future<void> exportarYCompartir(Seccion seccion, List<Alumno> alumnos) async {
    // 1. Generar contenido CSV usando las variables reales de tu modelo actual
    String contenido = "Alumno,Nota\n";
    
    for (var a in alumnos) {
      String notaStr = a.notaRendimiento?.toString() ?? "Pendiente";
      contenido += "${a.nombreCompleto},$notaStr\n";
    }

    // 2. Crear archivo temporal en el celular
    final directorio = await getTemporaryDirectory();
    final nombreLimpio = seccion.nombre.replaceAll(' ', '_');
    final ruta = "${directorio.path}/Notas_$nombreLimpio.csv";
    final archivo = File(ruta);
    await archivo.writeAsString(contenido);

    // 3. Abrir el menú nativo para enviar por WhatsApp
    await Share.shareXFiles(
      [XFile(ruta)], 
      text: 'Adjunto el registro de notas de la clase: ${seccion.nombre}'
    );
  }
}