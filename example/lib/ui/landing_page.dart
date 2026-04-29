import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_example/navigation/routers.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  'MAAC Architecture',
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore the power of MVVM with clean lifecycle management.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView(
                    children: [
                      _TutorialCard(
                        title: '01. Basic MVVM',
                        description: 'Learn the core concepts of ViewModels and StreamData binding.',
                        icon: Icons.layers_outlined,
                        color: Colors.blue,
                        onTap: () => context.push(AppRoutes.basic),
                      ),
                      const SizedBox(height: 16),
                      _TutorialCard(
                        title: '02. DI Integration',
                        description: 'Decouple your dependencies using GetIt and DependencyViewModelWidget.',
                        icon: Icons.settings_input_component_outlined,
                        color: Colors.purple,
                        onTap: () => context.push(AppRoutes.di),
                      ),
                      const SizedBox(height: 16),
                      _TutorialCard(
                        title: '03. Full Power',
                        description: 'Automate everything with Annotations and Code Generation.',
                        icon: Icons.bolt_outlined,
                        color: Colors.orange,
                        onTap: () => context.push(AppRoutes.full),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TutorialCard({required this.title, required this.description, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.1), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
