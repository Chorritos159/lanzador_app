import 'package:flutter/material.dart';
import 'presentation/screens/verificacion_conexion_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LanzadorApp());
}

class LanzadorApp extends StatelessWidget {
  const LanzadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Lanzador',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 23, 23, 23),
        scaffoldBackgroundColor: const Color(0xFFF4F4F6),
      ),
      home: const VerificacionConexionScreen(),
    );
  }
}