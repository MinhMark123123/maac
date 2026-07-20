import 'package:flutter/material.dart';

import 'di/service_locator.dart';
import 'sequential_api_flow/sequential_api_page.dart';
import 'signup_flow/signup_page.dart';
import 'single_flight_flow/single_flight_page.dart';

void main() {
  registerViewModels();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAAC Workflow Engine Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        cardTheme: const CardThemeData(
          color: Color(0xFF181822),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.alt_route,
                size: 72,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'MAAC Workflow Engine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Interactive verification dashboard for the Step Pipeline Engine',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildShowcaseCard(
                        context: context,
                        icon: Icons.account_tree_outlined,
                        title: 'Signup Wizard Flow',
                        description: 'A 3-step interactive screen stepper demonstrating dynamic navigation, conditional execution, and LIFO transaction rollback on failure.',
                        destination: const SignupFlowPage(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildShowcaseCard(
                        context: context,
                        icon: Icons.sync_alt,
                        title: 'Sequential APIs',
                        description: 'Simulates API chains with step-level Timeout decorators and Exponential Backoff Auto-Retry policy settings.',
                        destination: const SequentialApiFlowPage(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildShowcaseCard(
                        context: context,
                        icon: Icons.electric_bolt_outlined,
                        title: 'Single-Flight Run',
                        description: 'Demonstrates SingleFlightWorkflowRunner by mashing click events, automatically cancelling active runs to finish only the latest.',
                        destination: const SingleFlightFlowPage(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                'Powered by MinhMark123123/maac',
                style: TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget destination,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 36),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22222E),
                foregroundColor: Colors.cyanAccent,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.cyanAccent, width: 0.8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => destination),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enter Showcase', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
