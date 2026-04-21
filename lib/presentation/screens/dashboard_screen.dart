import 'package:flutter/material.dart';
import 'secciones_screen.dart';
import 'bluetooth_connection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _velocidad = 5.0;
  String _modoActivo = 'Fútbol';
  String _logMensaje = 'Esperando conexión...';

  void _enviarComandoLanzamiento() {
    setState(() {
      _logMensaje =
          'Enviando Comando -> Modo: $_modoActivo | Vel: ${_velocidad.toInt()}';
    });
  }

  void _activarParadaEmergencia() {
    setState(() {
      _logMensaje = 'PARADA DE EMERGENCIA ACTIVADA';
      _velocidad = 1.0;
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
            icon: const Icon(Icons.bluetooth, color: Color(0xFF2563EB)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const BluetoothConnectionScreen()),
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

            const Spacer(),

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
