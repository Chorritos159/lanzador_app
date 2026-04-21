import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/alumno_model.dart';
import '../domain/seccion_model.dart';
import 'database_helper.dart';

class ExportService {
  static Future<void> exportarYCompartir(
      Seccion seccion, List<Alumno> alumnos) async {
    final db = DatabaseHelper.instance;
    final sesiones = seccion.id != null
        ? await db.getSesionesPorSeccion(seccion.id!)
        : [];

    // Cabecera
    final headerParts = ['N\u00b0', 'Nombre', 'Apellido'];
    for (int i = 0; i < sesiones.length; i++) {
      final dt = DateTime.tryParse(sesiones[i].fecha);
      final label = dt != null
          ? 'Sesi\u00f3n ${i + 1} (${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')})'
          : 'Sesi\u00f3n ${i + 1}';
      headerParts.add(label);
    }
    if (sesiones.isNotEmpty) headerParts.add('Promedio');

    final buffer = StringBuffer();
    buffer.writeln(headerParts.join(','));

    for (int i = 0; i < alumnos.length; i++) {
      final alumno = alumnos[i];
      final row = <String>[
        '${i + 1}',
        alumno.nombre,
        alumno.apellido,
      ];

      double suma = 0;
      int count = 0;
      for (final sesion in sesiones) {
        if (alumno.id == null || sesion.id == null) {
          row.add('Pendiente');
          continue;
        }
        final nota =
            await db.getNotaDeAlumnoEnSesion(alumno.id!, sesion.id!);
        if (nota != null) {
          row.add(nota.nota.toStringAsFixed(1));
          suma += nota.nota;
          count++;
        } else {
          row.add('Pendiente');
        }
      }
      if (sesiones.isNotEmpty) {
        row.add(count > 0
            ? (suma / count).toStringAsFixed(1)
            : 'Pendiente');
      }
      buffer.writeln(row.join(','));
    }

    final directorio = await getTemporaryDirectory();
    final nombreLimpio = seccion.nombre.replaceAll(' ', '_');
    final ruta = '${directorio.path}/Notas_$nombreLimpio.csv';
    await File(ruta).writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(ruta, mimeType: 'text/csv')],
        text: 'Lista y notas de rendimiento \u2014 ${seccion.nombre}',
        subject: 'Notas ${seccion.nombre}',
      ),
    );
  }
}