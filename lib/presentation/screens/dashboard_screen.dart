import 'package:flutter/material.dart';
import 'alumnos_screen.dart';
import 'secciones_screen.dart'; 
import '../../data/lanzador_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _deporteSeleccionado = 'Fútbol';
  double _potencia = 5.0;
  String _estadoConexion = 'Esperando conexión Wi-Fi con el Lanzador...';
  bool _estaCargando = false; 
  IconData? _iconoEstado;
  Color _colorIconoEstado = const Color.fromARGB(255, 95, 103, 99);

  // --- LÓGICA DE RED (HABLAR CON EL ESP32) ---
  Future<void> _ejecutarLanzamiento() async {
    setState(() {
      _estadoConexion = 'Enviando comando de lanzamiento...';
      _estaCargando = true;
      _iconoEstado = null;
    });
    
    bool exito = await LanzadorService.iniciarLanzamiento(_deporteSeleccionado, _potencia);
    
    setState(() {
      _estaCargando = false;
      if (exito) {
        _estadoConexion = '¡Lanzamiento en curso! ($_deporteSeleccionado - Potencia ${_potencia.toInt()})';
        _iconoEstado = Icons.check_circle_outline;
        _colorIconoEstado = Colors.blueAccent;
      } else {
        _estadoConexion = 'Error: No se pudo conectar. Verifica que estés conectado al Wi-Fi del Lanzador.';
        _iconoEstado = Icons.wifi_off;
        _colorIconoEstado = Colors.redAccent;
      }
    });
  }

  Future<void> _detenerMotores() async {
    setState(() {
      _estadoConexion = 'Intentando detener motores...';
      _estaCargando = true;
      _iconoEstado = null;
    });

    bool exito = await LanzadorService.detenerMotores();
    
    setState(() {
      _estaCargando = false;
      if (exito) {
        _estadoConexion = 'MOTORES DETENIDOS POR SEGURIDAD';
        _iconoEstado = Icons.stop_circle_outlined;
        _colorIconoEstado = Colors.white70;
      } else {
        _estadoConexion = 'FALLO AL DETENER: ¡Si la máquina sigue moviéndose, corta la energía manual!';
        _iconoEstado = Icons.warning_amber_rounded;
        _colorIconoEstado = Colors.redAccent;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Control de Lanzador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: Colors.blueAccent),
            tooltip: 'Gestión de Aulas',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SeccionesScreen()));
            },
          ),
          const Icon(Icons.wifi, color: Colors.white70),
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

              Center(
                child: Image.asset(
                  'assets/images/logoexitus.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBotonDeporte('Fútbol', Icons.sports_soccer),
                  _buildBotonDeporte('Vóley', Icons.sports_volleyball),
                ],
              ),
              
              const SizedBox(height: 40),

              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Potencia del Motor',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_potencia.toInt()} / 10',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _potencia,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: const Color(0xFF3B82F6),
                        inactiveColor: Colors.grey[700],
                        thumbColor: Colors.white,
                        onChanged: (valor) {
                          setState(() {
                            _potencia = valor;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Mín', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          Text('Máx', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: _estadoConexion.contains('Error') || _estadoConexion.contains('FALLO') 
                        ? Colors.redAccent 
                        : (_estaCargando ? Colors.orangeAccent : Colors.blueAccent)
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
                    if (!_estaCargando && _iconoEstado != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(_iconoEstado, color: _colorIconoEstado, size: 22),
                      ),
                    Expanded(
                      child: Text(
                        _estadoConexion,
                        style: TextStyle(
                          color: _estadoConexion.contains('Error') || _estadoConexion.contains('FALLO') 
                              ? Colors.redAccent 
                              : Colors.white, 
                          fontFamily: 'monospace'
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                ),
                onPressed: _estaCargando ? null : _ejecutarLanzamiento,
                child: const Text(
                  'INICIAR LANZAMIENTO',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

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
          color: seleccionado ? const Color.fromARGB(255, 59, 130, 246) : Colors.grey[850],
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