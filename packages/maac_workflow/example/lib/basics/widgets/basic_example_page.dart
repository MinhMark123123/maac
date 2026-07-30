import 'package:flutter/material.dart';

/// Shared scaffold for every "Basics" example: title, one-paragraph
/// explanation, a Run button, and a scrolling log console. Deliberately
/// bare — no ViewModel/DI, no dark cyberpunk theming like the advanced
/// showcase flows — so each example reads as "just the maac_workflow API",
/// not entangled with maac_mvvm concepts a first-time reader hasn't met yet.
class BasicExamplePage extends StatefulWidget {
  final String title;
  final String description;
  final Future<void> Function(void Function(String message) log) onRun;
  final String runLabel;
  final Widget? controls;

  const BasicExamplePage({
    super.key,
    required this.title,
    required this.description,
    required this.onRun,
    this.runLabel = 'Run',
    this.controls,
  });

  @override
  State<BasicExamplePage> createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<BasicExamplePage> {
  final List<String> _logs = [];
  bool _running = false;

  void _log(String message) {
    if (!mounted) return;
    setState(() => _logs.add(message));
  }

  Future<void> _run() async {
    setState(() {
      _logs.clear();
      _running = true;
    });
    await widget.onRun(_log);
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.description, style: Theme.of(context).textTheme.bodyMedium),
            if (widget.controls != null) ...[const SizedBox(height: 16), widget.controls!],
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _running ? null : _run, child: Text(_running ? 'Running…' : widget.runLabel)),
            const SizedBox(height: 16),
            const Text('Output', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
                child: _logs.isEmpty
                    ? const Text('No output yet.', style: TextStyle(color: Colors.grey))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, i) => Text(_logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
