import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../data/export_service.dart';
import '../../domain/alumno_model.dart';
import '../../domain/seccion_model.dart';
import '../../domain/nota_model.dart';

class AlumnosScreen extends StatefulWidget {
  final Seccion seccion;
  const AlumnosScreen({super.key, required this.seccion});

  @override
  State<AlumnosScreen> createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  List<Alumno> _alumnos = [];
  Map<int, List<Nota>> _notasPorAlumno = {};
  List<String> _columnasEvaluacion = []; 

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _evaluacionController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  Future<void> _cargarAlumnos() async {
    if (widget.seccion.id != null) {
      final alumnosBD = await DatabaseHelper.instance.getAlumnosPorSeccion(widget.seccion.id!);
      
      Map<int, List<Nota>> notasMap = {};
      Set<String> columnasSet = {};

      for (var alumno in alumnosBD) {
        final notas = await DatabaseHelper.instance.getNotasPorAlumno(alumno.id!);
        notasMap[alumno.id!] = notas;
        for (var nota in notas) {
          columnasSet.add(nota.nombreEvaluacion);
        }
      }

      setState(() {
        _alumnos = alumnosBD;
        _notasPorAlumno = notasMap;
        _columnasEvaluacion = columnasSet.toList();
      });
    }
  }

  Future<void> _agregarAlumno() async {
    if (_nombreController.text.isEmpty || widget.seccion.id == null) return;
    
    final nuevoAlumno = Alumno(seccionId: widget.seccion.id!, nombreCompleto: _nombreController.text);
    await DatabaseHelper.instance.insertAlumno(nuevoAlumno);
    
    _nombreController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  Future<void> _guardarNota(Alumno alumno) async {
    if (_notaController.text.isEmpty || _evaluacionController.text.isEmpty || alumno.id == null) return;
    
    double? nota = double.tryParse(_notaController.text);
    if (nota != null) {
      final nuevaNota = Nota(
        alumnoId: alumno.id!,
        nombreEvaluacion: _evaluacionController.text.trim(),
        valor: nota
      );
      await DatabaseHelper.instance.insertNota(nuevaNota);
    }
    
    _notaController.clear();
    _evaluacionController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  void _mostrarDialogoNuevoAlumno() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Registrar Alumno', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nombreController,
          decoration: const InputDecoration(hintText: 'Nombre completo', hintStyle: TextStyle(color: Colors.grey)),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: _agregarAlumno,
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCargaMasiva() {
    final TextEditingController bulkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Importación Masiva', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: bulkController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Pega aquí la lista de alumnos\n(Un nombre por línea)',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              List<String> nombres = bulkController.text.split('\n');
              await DatabaseHelper.instance.insertarAlumnosMasivo(widget.seccion.id!, nombres);
              Navigator.pop(context);
              _cargarAlumnos(); 
            },
            child: const Text('Importar Ahora', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNota(Alumno alumno, {String? evaluacionExistente}) {
    if (evaluacionExistente != null) {
      _evaluacionController.text = evaluacionExistente;
    } else {
      _evaluacionController.clear();
    }
    _notaController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Evaluar a ${alumno.nombreCompleto}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _evaluacionController,
              enabled: evaluacionExistente == null, 
              decoration: InputDecoration(
                labelText: 'Nombre Eval.', 
                hintText: 'Ej: Práctica 1', 
                labelStyle: const TextStyle(color: Colors.blueAccent),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: evaluacionExistente != null,
                fillColor: evaluacionExistente != null ? Colors.grey[800] : Colors.transparent,
              ),
              style: TextStyle(color: evaluacionExistente == null ? Colors.white : Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _notaController,
              autofocus: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Nota (Ej: 18.5)', labelStyle: TextStyle(color: Colors.blueAccent)),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _evaluacionController.clear();
              _notaController.clear();
              Navigator.pop(context);
            }, 
            child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () => _guardarNota(alumno),
            child: const Text('Asignar Nota', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Nota? _obtenerNota(List<Nota> notas, String columna) {
    for (var n in notas) {
      if (n.nombreEvaluacion == columna) return n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: Text('Clase: ${widget.seccion.nombre}'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.blueAccent),
            tooltip: 'Importar Lista de Alumnos',
            onPressed: _mostrarDialogoCargaMasiva,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.greenAccent),
            tooltip: 'Exportar Notas',
            onPressed: () async {
              if (_alumnos.isEmpty) return;
              await ExportService.exportarYCompartir(widget.seccion, _alumnos, _columnasEvaluacion, _notasPorAlumno);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _alumnos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aula vacía.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                    icon: const Icon(Icons.content_paste, color: Colors.blueAccent),
                    label: const Text('Pegar lista de alumnos', style: TextStyle(color: Colors.white)),
                    onPressed: _mostrarDialogoCargaMasiva,
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal, 
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: anchoPantalla),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[850]),
                    columns: [
                      const DataColumn(label: Text('ALUMNO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ..._columnasEvaluacion.map((col) => DataColumn(label: Text(col.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                      const DataColumn(label: Text('NUEVA COLUMNA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    ],
                    rows: _alumnos.map((alumno) {
                      final notasAlumno = _notasPorAlumno[alumno.id] ?? [];
                      return DataRow(
                        cells: [
                          DataCell(Text(alumno.nombreCompleto, style: const TextStyle(color: Colors.white))),
                          ..._columnasEvaluacion.map((col) {
                            final notaObj = _obtenerNota(notasAlumno, col);
                            if (notaObj != null) {
                              return DataCell(
                                Text(notaObj.valor.toString(), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16))
                              );
                            } else {
                              return DataCell(
                                InkWell(
                                  onTap: () => _mostrarDialogoNota(alumno, evaluacionExistente: col),
                                  child: const Center(child: Icon(Icons.add_circle_outline, color: Colors.grey, size: 24)),
                                )
                              );
                            }
                          }),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.add_box, color: Colors.blueAccent),
                              onPressed: () => _mostrarDialogoNota(alumno), 
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        tooltip: 'Añadir un solo alumno',
        onPressed: _mostrarDialogoNuevoAlumno,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }
}