import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:maac_workflow_example/common/logging_view_model.dart';

import 'counter_context.dart';
import 'single_flight_view_model.dart';

class SingleFlightFlowPage extends DependencyViewModelWidget<SingleFlightViewModel> {
  const SingleFlightFlowPage({super.key});

  @override
  Widget build(BuildContext context, SingleFlightViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        title: const Text(
          'SingleFlight Execution Showcase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16161B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Control Panel & Click visualizer
          Expanded(
            flex: 6,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Single-Flight Execution',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: viewModel.clearLogs,
                            icon: const Icon(Icons.refresh, color: Colors.cyanAccent, size: 18),
                            label: const Text('Reset', style: TextStyle(color: Colors.cyanAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Click the button below rapidly. The SingleFlightRunner automatically cancels any active in-flight workflow and lets only the latest one execute.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: viewModel.triggerClick,
                        icon: const Icon(Icons.touch_app, size: 28),
                        label: const Text(
                          'MASH ME / FETCH COUNTER',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Visual Flight Status Monitor:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: StreamDataConsumer<List<ExecutionTracker>>(
                          streamData: viewModel.trackers,
                          builder: (context, list) {
                            if (list.isEmpty) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: const Text(
                                    'Click the button above multiple times to begin.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, idx) {
                                final item = list[idx];
                                return _buildTrackerTile(item);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Live Console
          Expanded(
            flex: 4,
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
                        streamData: viewModel.eventLog,
                        builder: (context, logs) {
                          if (logs.isEmpty) {
                            return const Center(
                              child: Text('No telemetry logs captured.', style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              Color textColor = Colors.greenAccent;
                              if (log.contains('cancelled') || log.contains('abort') || log.contains('intercepted')) {
                                textColor = Colors.redAccent;
                              } else if (log.contains('---')) {
                                textColor = Colors.cyanAccent;
                              } else if (log.contains('[SingleFlight]')) {
                                textColor = Colors.purpleAccent;
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  log,
                                  style: TextStyle(fontFamily: 'monospace', color: textColor, fontSize: 13),
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

  Widget _buildTrackerTile(ExecutionTracker tracker) {
    Color statusColor = Colors.cyanAccent;
    IconData statusIcon = Icons.hourglass_empty;
    String statusText = 'ACTIVE';

    if (tracker.status == ExecutionStatus.cancelled) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.cancel;
      statusText = 'CANCELLED';
    } else if (tracker.status == ExecutionStatus.completed) {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.check_circle;
      statusText = 'COMPLETED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Click / Request #${tracker.clickIndex}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(tracker.result ?? 'Simulated backend fetch in progress...', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
