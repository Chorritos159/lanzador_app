import 'package:flutter/material.dart';
// Importamos la pantalla de alumnos y el servicio del hardware
import 'alumnos_screen.dart';
import 'secciones_screen.dart'; // Asegúrate de tener este archivo para navegar a las clases
import '../../data/lanzador_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variables de estado
  String _deporteSeleccionado = 'Fútbol';
  double _potencia = 5.0;
  String _estadoConexion = 'Esperando conexión Wi-Fi con el Lanzador...';
  bool _estaCargando = false; // Para evitar que el profesor presione el botón 100 veces seguidas

  // --- LÓGICA DE RED (HABLAR CON EL ESP32) ---
  Future<void> _ejecutarLanzamiento() async {
    setState(() {
      _estadoConexion = 'Enviando comando de lanzamiento...';
      _estaCargando = true;
    });
    
    // Aquí la app se pausa unos segundos esperando al ESP32
    bool exito = await LanzadorService.iniciarLanzamiento(_deporteSeleccionado, _potencia);
    
    setState(() {
      _estaCargando = false;
      if (exito) {
        _estadoConexion = '✅ ¡Lanzamiento en curso! ($_deporteSeleccionado - Potencia ${_potencia.toInt()})';
      } else {
        _estadoConexion = '❌ Error: No se pudo conectar. Verifica que estés conectado al Wi-Fi del Lanzador.';
      }
    });
  }

  Future<void> _detenerMotores() async {
    setState(() {
      _estadoConexion = 'Intentando detener motores...';
      _estaCargando = true;
    });

    bool exito = await LanzadorService.detenerMotores();
    
    setState(() {
      _estaCargando = false;
      if (exito) {
        _estadoConexion = '🛑 MOTORES DETENIDOS POR SEGURIDAD';
      } else {
        _estadoConexion = '⚠️ FALLO AL DETENER: ¡Si la máquina sigue moviéndose, corta la energía manual!';
      }
    });
  }

  // --- INTERFAZ VISUAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Control de Lanzador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botón para ir a la gestión de alumnos
          IconButton(
            icon: const Icon(Icons.people, color: Colors.blueAccent),
            tooltip: 'Gestión de Aulas',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SeccionesScreen()));
            },
          ),
          const Icon(Icons.wifi, color: Colors.greenAccent),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              
              // --- BOTONES DE DEPORTE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBotonDeporte('Fútbol', Icons.sports_soccer),
                  _buildBotonDeporte('Vóley', Icons.sports_volleyball),
                ],
              ),
              
              const SizedBox(height: 40),

              // --- SLIDER DE POTENCIA ---
              Text(
                'Potencia del Motor: ${_potencia.toInt()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _potencia,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.greenAccent,
                inactiveColor: Colors.grey[800],
                onChanged: (valor) {
                  setState(() {
                    _potencia = valor;
                  });
                },
              ),

              const SizedBox(height: 30),

              // --- PANTALLA DE ESTADO ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    // Si hay error se pone rojo, si está cargando naranja, si no verde
                    color: _estadoConexion.contains('Error') || _estadoConexion.contains('FALLO') 
                        ? Colors.redAccent 
                        : (_estaCargando ? Colors.orangeAccent : Colors.greenAccent)
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_estaCargando) 
                      const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2)),
                      ),
                    Expanded(
                      child: Text(
                        _estadoConexion,
                        style: TextStyle(
                          color: _estadoConexion.contains('Error') || _estadoConexion.contains('FALLO') 
                              ? Colors.redAccent 
                              : Colors.greenAccent, 
                          fontFamily: 'monospace'
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÓN INICIAR LANZAMIENTO ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  // Desactivamos el botón si ya está enviando una petición
                  disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                ),
                onPressed: _estaCargando ? null : _ejecutarLanzamiento,
                child: const Text(
                  'INICIAR LANZAMIENTO',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // --- BOTÓN PARADA DE EMERGENCIA ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.5),
                ),
                onPressed: _estaCargando ? null : _detenerMotores,
                child: const Text(
                  'PARADA DE EMERGENCIA',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonDeporte(String nombre, IconData icono) {
    bool seleccionado = _deporteSeleccionado == nombre;
    return GestureDetector(
      onTap: () {
        setState(() {
          _deporteSeleccionado = nombre;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.greenAccent : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? Colors.black : Colors.white),
            const SizedBox(width: 8),
            Text(
              nombre,
              style: TextStyle(
                color: seleccionado ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}