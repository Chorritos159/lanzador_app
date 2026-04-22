import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../domain/seccion_model.dart';
import 'alumnos_screen.dart';

class SeccionesScreen extends StatefulWidget {
  const SeccionesScreen({super.key});

  @override
  State<SeccionesScreen> createState() => _SeccionesScreenState();
}

class _SeccionesScreenState extends State<SeccionesScreen> {
  List<Seccion> _secciones = [];
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarSecciones();
  }

  Future<void> _cargarSecciones() async {
    final seccionesBD = await DatabaseHelper.instance.getSecciones();
    setState(() {
      _secciones = seccionesBD;
    });
  }

  Future<void> _agregarSeccion() async {
    if (_nombreController.text.isEmpty) return;
    
    final nuevaSeccion = Seccion(nombre: _nombreController.text);
    await DatabaseHelper.instance.insertSeccion(nuevaSeccion);
    
    _nombreController.clear();
    Navigator.pop(context); 
    _cargarSecciones(); 
  }

  void _mostrarDialogoNuevaSeccion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Nueva Aula'),
        content: TextField(
          controller: _nombreController,
          decoration: const InputDecoration(
            hintText: 'Ej. 3ro A - Secundaria',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: _agregarSeccion,
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Aulas'),
        backgroundColor: Colors.black,
      ),
      body: _secciones.isEmpty
          ? const Center(child: Text('No hay aulas registradas. ¡Agrega una!', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              itemCount: _secciones.length,
              itemBuilder: (context, index) {
                final seccion = _secciones[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.class_, color: Colors.blueAccent),
                    title: Text(seccion.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlumnosScreen(seccion: seccion),
                                  ),
                                );
                              },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: _mostrarDialogoNuevaSeccion,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}