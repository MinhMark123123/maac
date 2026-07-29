import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'basics/basics_page.dart';
import 'basics/composites/conditional_step_basic_example.dart';
import 'basics/composites/parallel_step_group_basic_example.dart';
import 'basics/composites/retry_decorator_basic_example.dart';
import 'basics/composites/timeout_decorator_basic_example.dart';
import 'basics/composites/workflow_step_group_basic_example.dart';
import 'basics/concurrency/managed_workflow_runner_basic_example.dart';
import 'basics/concurrency/parallel_workflow_runner_basic_example.dart';
import 'basics/concurrency/shared_workflow_runner_basic_example.dart';
import 'basics/core/basic_run_example.dart';
import 'basics/core/cancellation_basic_example.dart';
import 'basics/core/flow_context_basic_example.dart';
import 'basics/core/listener_basic_example.dart';
import 'basics/progress/progress_basic_example.dart';
import 'basics/step_definitions/action_step_basic_example.dart';
import 'basics/step_definitions/interactive_step_basic_example.dart';
import 'basics/step_definitions/sustained_step_basic_example.dart';
import 'di/service_locator.dart';
import 'sequential_api_flow/sequential_api_page.dart';
import 'signup_flow/pages/basic_info_page.dart';
import 'signup_flow/pages/failed_page.dart';
import 'signup_flow/pages/loading_page.dart';
import 'signup_flow/pages/optional_details_page.dart';
import 'signup_flow/pages/review_page.dart';
import 'signup_flow/pages/success_page.dart';
import 'signup_flow/pages/welcome_page.dart';
import 'signup_flow/signup_flow_shell.dart';
import 'signup_flow/signup_routes.dart';
import 'single_flight_flow/single_flight_page.dart';

void main() {
  registerViewModels();
  runApp(const MyApp());
}

/// go_router builds every nested `GoRoute.builder` *before* `ShellRoute`'s own
/// builder runs (it needs the built child to pass into the shell), i.e.
/// before `SignupFlowShell` is mounted and its coordinator is available. Each
/// step route is wrapped in a `Builder` so `SignupFlowScope.of(context)` is
/// only evaluated once actually built as a descendant of the shell — see
/// `SignupFlowScope`'s doc comment in `signup_flow_shell.dart`.
final GoRouter _appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/sequential-api', builder: (context, state) => const SequentialApiFlowPage()),
    GoRoute(path: '/single-flight', builder: (context, state) => const SingleFlightFlowPage()),
    GoRoute(path: '/basics', builder: (context, state) => const BasicsPage()),
    GoRoute(path: '/basics/flow-context', builder: (context, state) => const FlowContextBasicExamplePage()),
    GoRoute(path: '/basics/basic-run', builder: (context, state) => const BasicRunExamplePage()),
    GoRoute(path: '/basics/cancellation', builder: (context, state) => const CancellationBasicExamplePage()),
    GoRoute(path: '/basics/listener', builder: (context, state) => const ListenerBasicExamplePage()),
    GoRoute(path: '/basics/action-step', builder: (context, state) => const ActionStepBasicExamplePage()),
    GoRoute(path: '/basics/sustained-step', builder: (context, state) => const SustainedStepBasicExamplePage()),
    GoRoute(path: '/basics/interactive-step', builder: (context, state) => const InteractiveStepBasicExamplePage()),
    GoRoute(path: '/basics/conditional-step', builder: (context, state) => const ConditionalStepBasicExamplePage()),
    GoRoute(path: '/basics/workflow-step-group', builder: (context, state) => const WorkflowStepGroupBasicExamplePage()),
    GoRoute(path: '/basics/parallel-step-group', builder: (context, state) => const ParallelStepGroupBasicExamplePage()),
    GoRoute(path: '/basics/retry-decorator', builder: (context, state) => const RetryDecoratorBasicExamplePage()),
    GoRoute(path: '/basics/timeout-decorator', builder: (context, state) => const TimeoutDecoratorBasicExamplePage()),
    GoRoute(path: '/basics/progress', builder: (context, state) => const ProgressBasicExamplePage()),
    GoRoute(path: '/basics/managed-workflow-runner', builder: (context, state) => const ManagedWorkflowRunnerBasicExamplePage()),
    GoRoute(path: '/basics/parallel-workflow-runner', builder: (context, state) => const ParallelWorkflowRunnerBasicExamplePage()),
    GoRoute(path: '/basics/shared-workflow-runner', builder: (context, state) => const SharedWorkflowRunnerBasicExamplePage()),
    ShellRoute(
      builder: (context, state, child) => SignupFlowShell(state: state, child: child),
      routes: [
        GoRoute(path: SignupRoutes.root, builder: (context, state) => Builder(builder: (c) => WelcomePage(coordinator: SignupFlowScope.of(c)))),
        GoRoute(path: SignupRoutes.basicInfo, builder: (context, state) => Builder(builder: (c) => BasicInfoPage(coordinator: SignupFlowScope.of(c)))),
        GoRoute(path: SignupRoutes.loading, builder: (context, state) => const LoadingPage()),
        GoRoute(
          path: SignupRoutes.optionalDetails,
          builder: (context, state) => Builder(builder: (c) => OptionalDetailsPage(coordinator: SignupFlowScope.of(c))),
        ),
        GoRoute(path: SignupRoutes.review, builder: (context, state) => Builder(builder: (c) => ReviewPage(coordinator: SignupFlowScope.of(c)))),
        GoRoute(path: SignupRoutes.success, builder: (context, state) => Builder(builder: (c) => SuccessPage(coordinator: SignupFlowScope.of(c)))),
        GoRoute(path: SignupRoutes.failed, builder: (context, state) => Builder(builder: (c) => FailedPage(coordinator: SignupFlowScope.of(c)))),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _appRouter,
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildShowcaseCard(
                    context: context,
                    icon: Icons.school_outlined,
                    title: 'Basics',
                    description: 'One minimal, focused example per package concept — FlowContext, cancellation, listeners, and more.',
                    destination: '/basics',
                  ),
                ),
              ),
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
                        destination: SignupRoutes.root,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildShowcaseCard(
                        context: context,
                        icon: Icons.sync_alt,
                        title: 'Sequential APIs',
                        description: 'Simulates API chains with step-level Timeout decorators and Exponential Backoff Auto-Retry policy settings.',
                        destination: '/sequential-api',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildShowcaseCard(
                        context: context,
                        icon: Icons.electric_bolt_outlined,
                        title: 'Single-Flight Run',
                        description: 'Demonstrates ManagedWorkflowRunner(strategy: cancelExisting()) by mashing click events, automatically cancelling active runs to finish only the latest.',
                        destination: '/single-flight',
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
    required String destination,
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
              onPressed: () => context.go(destination),
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
