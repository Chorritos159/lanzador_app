import 'package:flutter/material.dart';
import 'secciones_screen.dart';
import 'verificacion_conexion_screen.dart';
import 'historial_sesiones_screen.dart';
import '../../data/database_helper.dart';
import '../../domain/sesion_model.dart';
import '../../domain/seccion_model.dart';
import '../../domain/registro_lanzamiento_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _velocidad = 5.0;
  String _modoActivo = 'Fútbol';

  // --- Sección activa ---
  Seccion? _seccionActiva;

  // --- Sesión actual ---
  int? _sesionId;
  int _lanzamientosEnSesion = 0;
  double _potenciaAcumulada = 0;

  @override
  void initState() {
    super.initState();
    _iniciarSesion();
  }

  Future<void> _iniciarSesion() async {
    final secciones = await DatabaseHelper.instance.getSecciones();
    final primera = secciones.isNotEmpty ? secciones.first : null;
    setState(() => _seccionActiva = primera);
    final sesion = Sesion(
      fecha: DateTime.now().toIso8601String(),
      totalLanzamientos: 0,
      potenciaPromedio: 0,
      seccionId: primera?.id,
    );
    final id = await DatabaseHelper.instance.insertSesion(sesion);
    setState(() => _sesionId = id);
  }

  Future<void> _enviarComandoLanzamiento() async {
    if (_sesionId == null) return;
    setState(() {
      _lanzamientosEnSesion++;
      _potenciaAcumulada += _velocidad;
    });

    final registro = RegistroLanzamiento(
      sesionId: _sesionId!,
      fecha: DateTime.now().toIso8601String(),
      modo: _modoActivo,
      potencia: _velocidad.toInt(),
      numeroDeLanzamiento: _lanzamientosEnSesion,
    );
    await DatabaseHelper.instance.insertRegistroLanzamiento(registro);

    // Actualizar totales de la sesión
    final promedio = _potenciaAcumulada / _lanzamientosEnSesion;
    await DatabaseHelper.instance.updateSesion(Sesion(
      id: _sesionId,
      fecha: DateTime.now().toIso8601String(),
      totalLanzamientos: _lanzamientosEnSesion,
      potenciaPromedio: promedio,
      seccionId: _seccionActiva?.id,
    ));
  }

  void _activarParadaEmergencia() {
    setState(() {
      _velocidad = 1.0;
    });
  }

  Future<void> _nuevaSesion() async {
    // Recargar secciones por si se agregaron nuevas
    final secciones = await DatabaseHelper.instance.getSecciones();

    if (!mounted) return;
    Seccion? seleccion = _seccionActiva;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Nueva sesión',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFF1A1A2E)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el aula',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 10),
              if (secciones.isEmpty)
                const Text(
                  'No hay aulas registradas. Crea una primero.',
                  style: TextStyle(
                      color: Color(0xFFD97706), fontSize: 13),
                )
              else
                ...secciones.map((s) => GestureDetector(
                      onTap: () => setS(() => seleccion = s),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: seleccion?.id == s.id
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: seleccion?.id == s.id
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.class_outlined,
                              size: 18,
                              color: seleccion?.id == s.id
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: seleccion?.id == s.id
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            if (seleccion?.id == s.id) ...
                              const [
                                Spacer(),
                                Icon(Icons.check_circle_rounded,
                                    size: 18, color: Color(0xFF2563EB)),
                              ],
                          ],
                        ),
                      ),
                    )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Iniciar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );

    // Solo crear nueva sesión si el usuario confirmó (presionó "Iniciar")
    if (result != true) return;
    if (!mounted) return;

    final sesion = Sesion(
      fecha: DateTime.now().toIso8601String(),
      totalLanzamientos: 0,
      potenciaPromedio: 0,
      seccionId: seleccion?.id,
    );
    final id = await DatabaseHelper.instance.insertSesion(sesion);
    setState(() {
      _seccionActiva = seleccion;
      _sesionId = id;
      _lanzamientosEnSesion = 0;
      _potenciaAcumulada = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Control de Lanzador',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined,
                color: Color(0xFF6B7280)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SeccionesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.wifi, color: Color(0xFF2563EB)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const VerificacionConexionScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Modo de juego ---
            const Text(
              'Modo de juego',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildModoButton(
                        'Fútbol', 'Fútbol', Icons.sports_soccer)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildModoButton(
                        'Vóley', 'Vóley', Icons.sports_volleyball)),
              ],
            ),

            const SizedBox(height: 28),

            // --- Control de velocidad ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Potencia del Motor',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_velocidad.toInt()} / 10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 18),
                    ),
                    child: Slider(
                      value: _velocidad,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: const Color(0xFF2563EB),
                      inactiveColor: const Color(0xFFE5E7EB),
                      onChanged: (val) {
                        setState(() => _velocidad = val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- Sesión actual ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sesión actual',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _nuevaSesion,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF16A34A)),
                              ),
                              child: const Text(
                                'Nueva sesión',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistorialSesionesScreen()),
                            ),
                            child: const Text(
                              'Ver historial',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Selector de aula
                  GestureDetector(
                    onTap: _nuevaSesion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.class_outlined,
                              size: 15, color: Color(0xFF6B7280)),
                          const SizedBox(width: 6),
                          Text(
                            _seccionActiva != null
                                ? _seccionActiva!.nombre
                                : 'Sin aula asignada',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _seccionActiva != null
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.unfold_more_rounded,
                              size: 14, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          Icons.sports_score_outlined,
                          'Lanzamientos',
                          '$_lanzamientosEnSesion',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatChip(
                          Icons.speed_outlined,
                          'Potencia prom.',
                          _lanzamientosEnSesion > 0
                              ? (_potenciaAcumulada / _lanzamientosEnSesion).toStringAsFixed(1)
                              : '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- Botones de acción ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _enviarComandoLanzamiento,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text(
                  'INICIAR LANZAMIENTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _activarParadaEmergencia,
                icon: const Icon(Icons.stop_circle_outlined, size: 22),
                label: const Text(
                  'PARADA DE EMERGENCIA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icono, String etiqueta, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModoButton(String titulo, String modo, IconData icono) {
    final bool isSelected = _modoActivo == modo;
    return GestureDetector(
      onTap: () => setState(() => _modoActivo = modo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              size: 28,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
