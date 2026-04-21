import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../domain/alumno_model.dart';
import '../../domain/seccion_model.dart';
import '../../data/export_service.dart';

class AlumnosScreen extends StatefulWidget {
  final Seccion seccion; // Recibe el aula desde la pantalla anterior

  const AlumnosScreen({super.key, required this.seccion});

  @override
  State<AlumnosScreen> createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  List<Alumno> _alumnos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  // Carga solo los alumnos de ESTA aula
  Future<void> _cargarAlumnos() async {
    if (widget.seccion.id != null) {
      final alumnosBD = await DatabaseHelper.instance.getAlumnosPorSeccion(widget.seccion.id!);
      setState(() {
        _alumnos = alumnosBD;
      });
    }
  }

  Future<void> _agregarAlumno() async {
    if (_nombreController.text.isEmpty || widget.seccion.id == null) return;
    
    final nuevoAlumno = Alumno(
      seccionId: widget.seccion.id!, 
      nombreCompleto: _nombreController.text
    );
    await DatabaseHelper.instance.insertAlumno(nuevoAlumno);
    
    _nombreController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  Future<void> _guardarNota(Alumno alumno) async {
    if (_notaController.text.isEmpty || alumno.id == null) return;
    
    double? nota = double.tryParse(_notaController.text);
    if (nota != null) {
      await DatabaseHelper.instance.updateNotaAlumno(alumno.id!, nota);
    }
    
    _notaController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  // --- MODALES (Ventanas emergentes) ---

  void _mostrarDialogoNuevoAlumno() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Registrar Alumno'),
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

  void _mostrarDialogoNota(Alumno alumno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Evaluar a ${alumno.nombreCompleto}'),
        content: TextField(
          controller: _notaController,
          // autofocus: true, // Hace que el teclado aparezca de inmediato
          keyboardType: const TextInputType.numberWithOptions(decimal: true), // numeros y letras
          decoration: const InputDecoration(
            hintText: 'Ej. 17.5', 
            hintStyle: TextStyle(color: Colors.grey)
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _notaController.clear(); // Limpiamos la memoria si cancela
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
  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clase: ${widget.seccion.nombre}'),
        backgroundColor: Colors.black,
        actions: [
          // --- BOTÓN DE COMPARTIR ---
          IconButton(
            icon: const Icon(Icons.share, color: Colors.greenAccent),
            onPressed: () async {
              if (_alumnos.isEmpty) return; // Si no hay alumnos, no hace nada
              await ExportService.exportarYCompartir(widget.seccion, _alumnos);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _alumnos.isEmpty
          ? const Center(child: Text('Sin alumnos. Registra uno nuevo.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Permite deslizar si la tabla crece
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[900]),
                  columns: const [
                    DataColumn(label: Text('ALUMNO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                    DataColumn(label: Text('NOTA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                    DataColumn(label: Text('ACCIÓN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                  ],
                  rows: _alumnos.map((alumno) {
                    final tieneNota = alumno.notaRendimiento != null;
                    return DataRow(
                      cells: [
                        DataCell(Text(alumno.nombreCompleto, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(
                          tieneNota ? alumno.notaRendimiento.toString() : '-',
                          style: TextStyle(color: tieneNota ? Colors.greenAccent : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                        )),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                            onPressed: () => _mostrarDialogoNota(alumno),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: _mostrarDialogoNuevoAlumno,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }
}