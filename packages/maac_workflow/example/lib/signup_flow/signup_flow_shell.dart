import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:maac_workflow/maac_workflow.dart';
import 'package:maac_workflow_example/common/logging_view_model.dart';

import 'signup_flow_view_model.dart';
import 'signup_routes.dart';

/// Exposes the shell's [SignupFlowViewModel] to nested step pages.
///
/// go_router evaluates every nested `GoRoute.builder` (which construct the
/// step page widgets) *before* calling `ShellRoute.builder` — i.e. before
/// [SignupFlowShell] itself is even mounted. So step pages can't resolve the
/// coordinator eagerly at route-builder time; they must read it lazily, once
/// actually built as a descendant of this scope (see the `Builder` wrapper
/// around each nested route in `main.dart`).
class SignupFlowScope extends InheritedWidget {
  final SignupFlowViewModel viewModel;

  const SignupFlowScope({super.key, required this.viewModel, required super.child});

  static SignupFlowViewModel of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SignupFlowScope>()!.viewModel;
  }

  @override
  bool updateShouldNotify(SignupFlowScope oldWidget) => viewModel != oldWidget.viewModel;
}

/// Persistent shell rendered by the `ShellRoute` wrapping every `/signup/*`
/// step route. Its `State` (and therefore [SignupFlowViewModel], resolved
/// once via [DependencyViewModelWidget]) stays mounted while [child] swaps
/// between nested step pages, so the [WorkflowRunner] survives navigation
/// between steps.
class SignupFlowShell extends DependencyViewModelWidget<SignupFlowViewModel> {
  final Widget child;
  final GoRouterState state;

  const SignupFlowShell({super.key, required this.child, required this.state});

  bool get _isTerminalScreen => state.matchedLocation == SignupRoutes.success || state.matchedLocation == SignupRoutes.failed;

  @override
  Widget build(BuildContext context, SignupFlowViewModel viewModel) {
    viewModel.attachRouter(GoRouter.of(context));

    return SignupFlowScope(viewModel: viewModel, child: _buildScaffold(context, viewModel));
  }

  Widget _buildScaffold(BuildContext context, SignupFlowViewModel viewModel) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        title: const Text(
          'Interactive Signup Workflow Showcase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16161B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isTerminalScreen)
            TextButton.icon(
              onPressed: viewModel.reset,
              icon: const Icon(Icons.home_outlined, color: Colors.cyanAccent),
              label: const Text(
                'Go Home',
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: _StepTracker(workflowRunner: viewModel.workflowRunner),
          ),
          Expanded(
            child: Row(
              children: [
                // Left panel: current step page
                Expanded(
                  flex: 6,
                  child: Padding(padding: const EdgeInsets.fromLTRB(32, 0, 32, 32), child: child),
                ),
                // Right panel: Live Console & Status
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
                                    child: Text('No telemetry events registered.', style: TextStyle(color: Colors.grey)),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    Color textColor = Colors.greenAccent;
                                    if (log.contains('Failure') || log.contains('Error') || log.contains('failed')) {
                                      textColor = Colors.redAccent;
                                    } else if (log.contains('Rollback')) {
                                      textColor = Colors.orangeAccent;
                                    } else if (log.contains('Interactive')) {
                                      textColor = Colors.purpleAccent;
                                    } else if (log.contains('Skip')) {
                                      textColor = Colors.grey;
                                    } else if (log.contains('[Engine]')) {
                                      textColor = Colors.cyanAccent.withOpacity(0.9);
                                    } else if (log.contains('Step')) {
                                      textColor = Colors.white70;
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
          ),
        ],
      ),
    );
  }
}

/// Renders `workflowRunner.progress` as a row of labelled dots — live proof
/// that current-step & per-step status tracking works across step page
/// navigation, driven purely by `WorkflowRunner.progress`.
class _StepTracker extends StatelessWidget {
  final WorkflowRunner<FlowContext> workflowRunner;
  const _StepTracker({required this.workflowRunner});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WorkflowProgress>(
      valueListenable: workflowRunner.progress,
      builder: (context, progress, _) {
        return Row(
          children: [
            for (var index = 0; index < signupStepDefinitions.length; index++) ...[
              if (index > 0) Expanded(child: Container(height: 2, color: Colors.white.withOpacity(0.08))),
              _StepDot(
                label: signupStepDefinitions[index].$2,
                status: progress.statusOf(signupStepDefinitions[index].$1) ?? StepStatus.pending,
                isCurrent: progress.currentStepId == signupStepDefinitions[index].$1,
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
      StepStatus.awaitingInput => (Colors.amberAccent, Icons.pause_circle_outline),
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
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
