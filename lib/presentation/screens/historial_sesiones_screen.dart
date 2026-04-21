import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../domain/sesion_model.dart';
import '../../domain/seccion_model.dart';
import '../../domain/registro_lanzamiento_model.dart';

class HistorialSesionesScreen extends StatefulWidget {
  const HistorialSesionesScreen({super.key});

  @override
  State<HistorialSesionesScreen> createState() =>
      _HistorialSesionesScreenState();
}

class _HistorialSesionesScreenState extends State<HistorialSesionesScreen> {
  List<Sesion> _sesiones = [];
  Map<int, Seccion> _seccionesMap = {};

  @override
  void initState() {
    super.initState();
    _cargarSesiones();
  }

  Future<void> _cargarSesiones() async {
    final data = await DatabaseHelper.instance.getSesiones();
    final secciones = await DatabaseHelper.instance.getSecciones();
    setState(() {
      _sesiones = data;
      _seccionesMap = {for (final s in secciones) s.id!: s};
    });
  }

  String _formatearFecha(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _abrirDetalle(Sesion sesion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DetalleSesionScreen(sesion: sesion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Historial de sesiones',
          style: TextStyle(
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
      ),
      body: _sesiones.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history, size: 56, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 16),
                  Text(
                    'Sin sesiones registradas',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Realiza tu primer lanzamiento para comenzar',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _sesiones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sesion = _sesiones[index];
                final numero = _sesiones.length - index;
                return GestureDetector(
                  onTap: () => _abrirDetalle(sesion),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
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
                              '$numero',
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
                                'Sesión $numero',
                                style: const TextStyle(
                                  color: Color(0xFF1A1A2E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (sesion.seccionId != null &&
                                  _seccionesMap.containsKey(sesion.seccionId))
                                Row(
                                  children: [
                                    const Icon(Icons.class_outlined,
                                        size: 11,
                                        color: Color(0xFF7C3AED)),
                                    const SizedBox(width: 3),
                                    Text(
                                      _seccionesMap[sesion.seccionId]!.nombre,
                                      style: const TextStyle(
                                        color: Color(0xFF7C3AED),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 2),
                              Text(
                                _formatearFecha(sesion.fecha),
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${sesion.totalLanzamientos}',
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'lanzamientos',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF9CA3AF), size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Pantalla de detalle de una sesión ---
class _DetalleSesionScreen extends StatefulWidget {
  final Sesion sesion;
  const _DetalleSesionScreen({required this.sesion});

  @override
  State<_DetalleSesionScreen> createState() => _DetalleSesionScreenState();
}

class _DetalleSesionScreenState extends State<_DetalleSesionScreen> {
  List<RegistroLanzamiento> _registros = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (widget.sesion.id == null) return;
    final data = await DatabaseHelper.instance
        .getRegistrosPorSesion(widget.sesion.id!);
    setState(() => _registros = data);
  }

  String _formatearFecha(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Registro completo',
          style: TextStyle(
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
      ),
      body: Column(
        children: [
          // Resumen de sesión
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumenItem(
                    'Total', '${widget.sesion.totalLanzamientos}', 'lanzamientos'),
                Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                _buildResumenItem(
                    'Potencia prom.',
                    widget.sesion.potenciaPromedio.toStringAsFixed(1),
                    'sobre 10'),
              ],
            ),
          ),

          // Encabezado tabla
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                    flex: 1,
                    child: Text('#',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF)))),
                Expanded(
                    flex: 3,
                    child: Text('Fecha y hora',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF)))),
                Expanded(
                    flex: 2,
                    child: Text('Modo',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF)))),
                Expanded(
                    flex: 1,
                    child: Text('Pot.',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF)))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _registros.isEmpty
                ? const Center(
                    child: Text('Sin registros',
                        style: TextStyle(color: Color(0xFF9CA3AF))))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _registros.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Color(0xFFE5E7EB), height: 1),
                    itemBuilder: (context, index) {
                      final r = _registros[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${r.numeroDeLanzamiento}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatearFecha(r.fecha),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                r.modo,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1A1A2E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${r.potencia}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
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
    );
  }

  Widget _buildResumenItem(String etiqueta, String valor, String unidad) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Text(
          unidad,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
