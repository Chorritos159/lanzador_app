import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../domain/alumno_model.dart';
import '../../domain/seccion_model.dart';
import '../../domain/sesion_model.dart';
import '../../domain/nota_sesion_model.dart';
import '../../data/export_service.dart';

class AlumnosScreen extends StatefulWidget {
  final Seccion seccion;

  const AlumnosScreen({super.key, required this.seccion});

  @override
  State<AlumnosScreen> createState() => _AlumnosScreenState();
}

class _AlumnosScreenState extends State<AlumnosScreen> {
  List<Alumno> _alumnos = [];
  List<Sesion> _sesiones = [];
  Map<int, int> _notasCount = {}; // alumnoId → cantidad de notas en esta sección
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (widget.seccion.id == null) return;
    final alumnos = await DatabaseHelper.instance
        .getAlumnosPorSeccion(widget.seccion.id!);
    final sesiones = await DatabaseHelper.instance
        .getSesionesPorSeccion(widget.seccion.id!);
    final count = await DatabaseHelper.instance
        .getNotasCountPorSeccion(widget.seccion.id!);
    setState(() {
      _alumnos = alumnos;
      _sesiones = sesiones;
      _notasCount = count;
    });
  }

  Future<void> _agregarAlumno() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    if (nombre.isEmpty || widget.seccion.id == null) return;
    final nuevoAlumno = Alumno(
      seccionId: widget.seccion.id!,
      nombre: nombre,
      apellido: apellido,
    );
    await DatabaseHelper.instance.insertAlumno(nuevoAlumno);
    _nombreController.clear();
    _apellidoController.clear();
    if (mounted) Navigator.pop(context);
    _cargar();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(
              controller: _nombreController,
              hint: 'Nombre',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _apellidoController,
              hint: 'Apellido',
              icon: Icons.person_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nombreController.clear();
              _apellidoController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF6B7280))),
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

  void _mostrarNotasPorSesion(Alumno alumno) {
    if (_sesiones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No hay sesiones registradas para este aula. Inicia una sesión desde el Dashboard.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotasPorSesionSheet(
        alumno: alumno,
        sesiones: _sesiones,
        onGuardado: _cargar,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final conNotas =
        _notasCount.values.where((v) => v > 0).length;
    final sinNotas = _alumnos.length - conNotas;

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
            icon: const Icon(Icons.ios_share_outlined,
                color: Color(0xFF2563EB)),
            tooltip: 'Exportar lista y notas',
            onPressed: () async {
              if (_alumnos.isEmpty) return;
              await ExportService.exportarYCompartir(
                  widget.seccion, _alumnos);
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
                  const Icon(Icons.people_outline,
                      size: 56, color: Color(0xFFD1D5DB)),
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
          : Column(
              children: [
                // Barra de resumen
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _buildResumenChip(
                        Icons.people_alt_outlined,
                        '${_alumnos.length}',
                        'Total',
                        const Color(0xFF2563EB),
                        const Color(0xFFEFF6FF),
                      ),
                      const SizedBox(width: 12),
                      _buildResumenChip(
                        Icons.event_note_outlined,
                        '${_sesiones.length}',
                        'Sesiones',
                        const Color(0xFF7C3AED),
                        const Color(0xFFF5F3FF),
                      ),
                      const SizedBox(width: 12),
                      _buildResumenChip(
                        Icons.hourglass_bottom_outlined,
                        '$sinNotas',
                        'Sin notas',
                        const Color(0xFFD97706),
                        const Color(0xFFFFFBEB),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: _alumnos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final alumno = _alumnos[index];
                      final nNotas = _notasCount[alumno.id] ?? 0;
                      final tieneNotas = nNotas > 0;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  alumno.nombre
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumno.nombreCompleto,
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        tieneNotas
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 14,
                                        color: tieneNotas
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tieneNotas
                                            ? '$nNotas ${nNotas == 1 ? 'nota' : 'notas'} registrada${nNotas == 1 ? '' : 's'}'
                                            : 'Sin notas',
                                        style: TextStyle(
                                          color: tieneNotas
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF9CA3AF),
                                          fontSize: 13,
                                          fontWeight: tieneNotas
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _mostrarNotasPorSesion(alumno),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: tieneNotas
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: tieneNotas
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                                child: Text(
                                  'Notas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: tieneNotas
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: _mostrarDialogoNuevoAlumno,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildResumenChip(IconData icon, String valor, String label,
      Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              valor,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sheet de notas por sesión de un alumno ---
class _NotasPorSesionSheet extends StatefulWidget {
  final Alumno alumno;
  final List<Sesion> sesiones;
  final VoidCallback onGuardado;

  const _NotasPorSesionSheet({
    required this.alumno,
    required this.sesiones,
    required this.onGuardado,
  });

  @override
  State<_NotasPorSesionSheet> createState() => _NotasPorSesionSheetState();
}

class _NotasPorSesionSheetState extends State<_NotasPorSesionSheet> {
  // sesionId → NotaSesion (si existe)
  Map<int, NotaSesion?> _notas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    final Map<int, NotaSesion?> mapa = {};
    for (final s in widget.sesiones) {
      if (s.id == null) continue;
      final nota = await DatabaseHelper.instance
          .getNotaDeAlumnoEnSesion(widget.alumno.id!, s.id!);
      mapa[s.id!] = nota;
    }
    if (mounted) {
      setState(() {
        _notas = mapa;
        _cargando = false;
      });
    }
  }

  String _formatFecha(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _editarNota(Sesion sesion, NotaSesion? existente) {
    final ctrl = TextEditingController(
        text: existente?.nota.toString() ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.alumno.nombreCompleto,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 2),
            Text(
              'Sesión del ${_formatFecha(sesion.fecha)}',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: 'Ej. 17.5',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: const Icon(Icons.star_outline_rounded,
                color: Color(0xFF9CA3AF), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final valor = double.tryParse(ctrl.text);
              if (valor == null) return;
              await DatabaseHelper.instance.upsertNotaSesion(NotaSesion(
                id: existente?.id,
                alumnoId: widget.alumno.id!,
                sesionId: sesion.id!,
                nota: valor,
              ));
              if (mounted) Navigator.pop(context);
              await _cargarNotas();
              widget.onGuardado();
            },
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        widget.alumno.nombre.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alumno.nombreCompleto,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const Text(
                          'Notas por sesión',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: widget.sesiones.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final sesion = widget.sesiones[i];
                        final nota = sesion.id != null
                            ? _notas[sesion.id!]
                            : null;
                        final numero = widget.sesiones.length - i;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '$numero',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sesión $numero',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A2E),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _formatFecha(sesion.fecha),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                              ),
                              if (nota != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    nota.nota.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () => _editarNota(sesion, nota),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: nota != null
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: nota != null
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                  child: Text(
                                    nota != null ? 'Editar' : 'Asignar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: nota != null
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
