import 'package:flutter/material.dart';
import 'presentation/screens/dashboard_screen.dart'; // Importamos tu nueva pantalla

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
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const DashboardScreen(), // Aquí cargamos el Dashboard
    );
  }
}