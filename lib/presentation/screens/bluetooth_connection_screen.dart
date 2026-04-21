import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'dashboard_screen.dart';

class BluetoothConnectionScreen extends StatelessWidget {
  const BluetoothConnectionScreen({super.key});

  void _openBluetoothSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status chip
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 224, 222, 222),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 167, 165, 165),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DESCONECTADO',
                        style: TextStyle(
                          color: Color.fromARGB(255, 167, 165, 165),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Bluetooth circle button
              GestureDetector(
                onTap: () => _goToDashboard(context),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 205, 205, 206),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 225, 223, 223).withOpacity(0.30),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Title
              const Text(
                'Verifica tu conexión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'No se detecta conexión con el dispositivo vía Bluetooth. Por favor, enciende el dispositivo y conéctate para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // Primary button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _openBluetoothSettings,
                  icon: const Icon(
                    Icons.bluetooth_searching,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: const Text(
                    'Buscar dispositivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 59, 130, 246),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 60),

              // Hint text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.smartphone_outlined,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Asegúrate de que el ',
                          ),
                          TextSpan(
                            text: 'Bluetooth',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' esté activado en tu teléfono y de que el dispositivo se encuentre cerca.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
