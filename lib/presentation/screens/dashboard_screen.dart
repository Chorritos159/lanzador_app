import 'package:flutter/material.dart';
import 'secciones_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variables de estado listas para enviar al ESP32
  String _deporteSeleccionado = 'Fútbol';
  double _potencia = 5.0;
  String _estadoConexion = 'Esperando conexión...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Control de Lanzador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SeccionesScreen()));
            },
          ),
          const Icon(Icons.wifi, color: Colors.greenAccent),
          const SizedBox(width: 15),
        ],
      ),
      //PERMITE GIRAR EL CELULAR
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

              // --- ESTADO DE CONEXIÓN ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _estadoConexion,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÓN INICIAR LANZAMIENTO ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: Aquí pondremos la petición HTTP POST al ESP32
                  setState(() {
                    _estadoConexion = 'Enviando comando de lanzamiento...';
                  });
                },
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
                ),
                onPressed: () {
                  // TODO: Petición HTTP POST de emergencia para apagar motores
                  setState(() {
                    _estadoConexion = '¡MOTORES DETENIDOS!';
                  });
                },
                child: const Text(
                  'PARADA DE EMERGENCIA',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40), // Espacio extra al final para que el scroll sea cómodo
            ],
          ),
        ),
      ),
    );
  }

  // Helper visual para los botones de Fútbol y Vóley
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