import 'package:flutter/material.dart';
import 'secciones_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _velocidad = 5.0;
  String _modoActivo = 'Fútbol';
  String _logMensaje = 'Esperando conexión...';

  // Esta función simulará el envío al ESP32 por ahora
  void _enviarComandoLanzamiento() {
    setState(() {
      _logMensaje = 'Enviando Comando -> Modo: $_modoActivo | Vel: ${_velocidad.toInt()}';
    });
    
    // TODO: Aquí integraremos la petición HTTP apuntando a:
    // AppConstants.esp32Ip en el próximo paso.
  }

  void _activarParadaEmergencia() {
    setState(() {
      _logMensaje = '¡PARADA DE EMERGENCIA ACTIVADA!';
      _velocidad = 1.0; // Reseteamos la velocidad por seguridad
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     title: const Text('Control de Lanzador', style: TextStyle(fontWeight: FontWeight.bold)),
     backgroundColor: Colors.black,
     actions: [
       IconButton(
         icon: const Icon(Icons.people_alt, color: Colors.white),
         onPressed: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const SeccionesScreen()),
           );
         },
       ),
       const SizedBox(width: 10),
       const Icon(Icons.wifi, color: Colors.greenAccent),
       const SizedBox(width: 20),
     ],
   ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --- Tarjetas de Selección de Modo ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModoButton('⚽ FÚTBOL', 'Fútbol'),
                _buildModoButton('🏐 VÓLEY', 'Vóley'),
              ],
            ),
            
            // --- Control de Velocidad (Slider) ---
            Column(
              children: [
                Text(
                  'Potencia del Motor: ${_velocidad.toInt()}', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _velocidad,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.grey[800],
                  onChanged: (val) {
                    setState(() => _velocidad = val);
                  },
                ),
              ],
            ),

            // --- Consola de Logs ---
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                _logMensaje, 
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')
              ),
            ),

            // --- Botón Principal de Acción ---
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _enviarComandoLanzamiento,
                child: const Text('INICIAR LANZAMIENTO', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

            // --- Botón de Emergencia (HU04) ---
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _activarParadaEmergencia,
                child: const Text('PARADA DE EMERGENCIA', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los botones de modo y mantener el código limpio
  Widget _buildModoButton(String titulo, String modo) {
    bool isSelected = _modoActivo == modo;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.greenAccent : Colors.grey[850],
        foregroundColor: isSelected ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () => setState(() => _modoActivo = modo),
      child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}