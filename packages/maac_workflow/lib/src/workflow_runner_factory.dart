import 'flow_context.dart';
import 'runner.dart';

/// Builds a fresh [WorkflowRunner] (with fresh step instances) for one
/// logical run. Concurrency-control wrappers ([ManagedWorkflowRunner],
/// [ParallelWorkflowRunner], [SharedWorkflowRunner]) call this once per
/// logical run rather than reusing a single instance, because both
/// [WorkflowRunner] and stateful steps (e.g. `InteractiveStep`) hold
/// per-instance mutable state that two overlapping runs can never safely
/// share.
typedef WorkflowRunnerFactory<TContext extends FlowContext> = WorkflowRunner<TContext> Function();
