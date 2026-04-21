import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../domain/alumno_model.dart';
import '../../domain/seccion_model.dart';
import '../../data/export_service.dart';

class AlumnosScreen extends StatefulWidget {
  final Seccion seccion;

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

  Future<void> _cargarAlumnos() async {
    if (widget.seccion.id != null) {
      final alumnosBD = await DatabaseHelper.instance
          .getAlumnosPorSeccion(widget.seccion.id!);
      setState(() {
        _alumnos = alumnosBD;
      });
    }
  }

  Future<void> _agregarAlumno() async {
    if (_nombreController.text.isEmpty || widget.seccion.id == null) return;
    final nuevoAlumno = Alumno(
      seccionId: widget.seccion.id!,
      nombreCompleto: _nombreController.text,
    );
    await DatabaseHelper.instance.insertAlumno(nuevoAlumno);
    _nombreController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  Future<void> _guardarNota(Alumno alumno) async {
    if (_notaController.text.isEmpty || alumno.id == null) return;
    final double? nota = double.tryParse(_notaController.text);
    if (nota != null) {
      await DatabaseHelper.instance.updateNotaAlumno(alumno.id!, nota);
    }
    _notaController.clear();
    Navigator.pop(context);
    _cargarAlumnos();
  }

  void _mostrarDialogoNuevoAlumno() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Registrar alumno',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: TextField(
          controller: _nombreController,
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'Nombre completo',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _agregarAlumno,
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNota(Alumno alumno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Evaluar a ${alumno.nombreCompleto}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: TextField(
          controller: _notaController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'Ej. 17.5',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _notaController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _guardarNota(alumno),
            child: const Text('Asignar nota',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.seccion.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, color: Color(0xFF2563EB)),
            onPressed: () async {
              if (_alumnos.isEmpty) return;
              await ExportService.exportarYCompartir(widget.seccion, _alumnos);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _alumnos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 56, color: const Color(0xFFD1D5DB)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin alumnos registrados',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toca + para agregar uno nuevo',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _alumnos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alumno = _alumnos[index];
                final tieneNota = alumno.notaRendimiento != null;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            alumno.nombreCompleto
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alumno.nombreCompleto,
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tieneNota
                                  ? 'Nota: ${alumno.notaRendimiento}'
                                  : 'Sin nota asignada',
                              style: TextStyle(
                                color: tieneNota
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontWeight: tieneNota
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Color(0xFF2563EB), size: 22),
                        onPressed: () => _mostrarDialogoNota(alumno),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _mostrarDialogoNuevoAlumno,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}
