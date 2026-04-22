import 'package:flutter/material.dart';
import 'presentation/screens/dashboard_screen.dart';  

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
        primaryColor:  const Color(0xFF121212),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const DashboardScreen(),
    );
  }
}