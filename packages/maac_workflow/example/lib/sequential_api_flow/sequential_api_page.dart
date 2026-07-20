import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'sequential_api_view_model.dart';

class SequentialApiFlowPage extends DependencyViewModelWidget<SequentialApiViewModel> {
  const SequentialApiFlowPage({super.key});

  @override
  Widget build(BuildContext context, SequentialApiViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        title: const Text('Sequential API & Decorators Showcase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF16161B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Control Panel
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                color: const Color(0xFF181822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Decorators Dashboard',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Configure custom decorators on steps. We wrap Profile fetch in a Timeout decorator, and Sync data in a Retry decorator.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      _StepTracker(viewModel: viewModel),
                      const Divider(color: Colors.white10, height: 32),

                      // Timeout Config
                      const Text('Step 2: Timeout Settings', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      StreamDataConsumer<bool>(
                        streamData: viewModel.forceTimeout,
                        builder: (context, val) {
                          return SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Simulate Slow Profiler Response', style: TextStyle(color: Colors.white, fontSize: 15)),
                            subtitle: const Text('Forces Profile API to take 5 seconds.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            value: val,
                            onChanged: viewModel.setForceTimeout,
                            activeColor: Colors.cyanAccent,
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Timeout Limit (seconds):', style: TextStyle(color: Colors.white70)),
                          DropdownButton<int>(
                            dropdownColor: const Color(0xFF1E1E28),
                            value: viewModel.timeoutLimitSeconds,
                            style: const TextStyle(color: Colors.cyanAccent),
                            items: [2, 3, 5, 8].map((e) => DropdownMenuItem(value: e, child: Text('$e seconds'))).toList(),
                            onChanged: (v) {
                              if (v != null) viewModel.timeoutLimitSeconds = v;
                            },
                          ),
                        ],
                      ),

                      const Divider(color: Colors.white10, height: 32),

                      // Retry Config
                      const Text('Step 3: Auto-Retry Settings', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      StreamDataConsumer<bool>(
                        streamData: viewModel.forceSyncError,
                        builder: (context, val) {
                          return SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Simulate Network Errors on Sync', style: TextStyle(color: Colors.white, fontSize: 15)),
                            subtitle: const Text('Forces Sync API to crash.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            value: val,
                            onChanged: viewModel.setForceSyncError,
                            activeColor: Colors.cyanAccent,
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Max Retry Attempts:', style: TextStyle(color: Colors.white70)),
                          DropdownButton<int>(
                            dropdownColor: const Color(0xFF1E1E28),
                            value: viewModel.retryAttempts,
                            style: const TextStyle(color: Colors.cyanAccent),
                            items: [2, 3, 5].map((e) => DropdownMenuItem(value: e, child: Text('$e attempts'))).toList(),
                            onChanged: (v) {
                              if (v != null) viewModel.retryAttempts = v;
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Actions
                      StreamDataConsumer<bool>(
                        streamData: viewModel.isRunning,
                        builder: (context, running) {
                          if (running) {
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: viewModel.cancelWorkflow,
                              icon: const Icon(Icons.stop),
                              label: const Text('Cancel / Terminate Running APIs', style: TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: viewModel.startFlow,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Execute Sequential Flow', style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Live telemetry monitor
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14141B),
                border: Border(left: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Engine Telemetry Logs',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        onPressed: viewModel.clearLogs,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0B0E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: StreamDataConsumer<List<String>>(
                        streamData: viewModel.workflowHistory,
                        builder: (context, logs) {
                          if (logs.isEmpty) {
                            return const Center(
                              child: Text('No telemetry logs captured yet. Press Play.', style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              Color textColor = Colors.greenAccent;
                              if (log.contains('Failure') || log.contains('Error') || log.contains('failed') || log.contains('Timeout')) {
                                textColor = Colors.redAccent;
                              } else if (log.contains('Attempt #')) {
                                textColor = Colors.amberAccent;
                              } else if (log.contains('[Engine]')) {
                                textColor = Colors.cyanAccent.withOpacity(0.9);
                              } else if (log.contains('Step')) {
                                textColor = Colors.white70;
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders `viewModel.stepProgress` (a `WorkflowRunner.progress` ValueListenable)
/// as a row of labelled dots — live proof that current-step & per-step status
/// tracking works without any extra plumbing through WorkflowListener.
class _StepTracker extends StatelessWidget {
  final SequentialApiViewModel viewModel;
  const _StepTracker({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WorkflowProgress>(
      valueListenable: viewModel.stepProgress,
      builder: (context, progress, _) {
        return Row(
          children: [
            for (var index = 0; index < apiStepDefinitions.length; index++) ...[
              if (index > 0)
                Expanded(
                  child: Container(height: 2, color: Colors.white.withOpacity(0.08)),
                ),
              _StepDot(
                label: apiStepDefinitions[index].$2,
                status: progress.statusOf(apiStepDefinitions[index].$1) ?? StepStatus.pending,
                isCurrent: progress.currentStepId == apiStepDefinitions[index].$1,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final StepStatus status;
  final bool isCurrent;

  const _StepDot({required this.label, required this.status, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      StepStatus.pending => (Colors.white24, Icons.circle_outlined),
      StepStatus.running || StepStatus.rollbackRunning => (Colors.cyanAccent, Icons.autorenew),
      StepStatus.success || StepStatus.rollbackSuccess => (Colors.greenAccent, Icons.check_circle),
      StepStatus.failed || StepStatus.rollbackFailed => (Colors.redAccent, Icons.cancel),
      StepStatus.skipped => (Colors.grey, Icons.remove_circle_outline),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color, width: isCurrent ? 2 : 1),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
