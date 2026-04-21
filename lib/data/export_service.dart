import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/alumno_model.dart';
import '../domain/seccion_model.dart';
import '../domain/nota_model.dart';

class ExportService {
  static Future<void> exportarYCompartir(
    Seccion seccion, 
    List<Alumno> alumnos, 
    List<String> columnas, 
    Map<int, List<Nota>> notasPorAlumno
  ) async {
    
    // 1. Crear las cabeceras (Ej: Alumno, PC1, PC2)
    String contenido = "Alumno";
    for (var col in columnas) {
      contenido += ",${col.toUpperCase()}";
    }
    contenido += "\n";
    
    // 2. Llenar los datos de cada estudiante
    for (var a in alumnos) {
      contenido += a.nombreCompleto;
      final notasDelAlumno = notasPorAlumno[a.id] ?? [];
      
      for (var col in columnas) {
        String valorNota = "-";
        for (var n in notasDelAlumno) {
          if (n.nombreEvaluacion == col) {
            valorNota = n.valor.toString();
          }
        }
        contenido += ",$valorNota";
      }
      contenido += "\n";
    }

    // 3. Crear archivo y compartir
    final directorio = await getTemporaryDirectory();
    final nombreLimpio = seccion.nombre.replaceAll(' ', '_');
    final ruta = "${directorio.path}/Notas_$nombreLimpio.csv";
    final archivo = File(ruta);
    await archivo.writeAsString(contenido);

    await Share.shareXFiles([XFile(ruta)], text: 'Registro de la clase: ${seccion.nombre}');
  }
}