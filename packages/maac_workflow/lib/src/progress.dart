import 'result.dart';

/// A live, queryable snapshot of a `WorkflowRunner`'s progress: which step is
/// currently executing (forward or rollback), and the last known [StepStatus]
/// of every step reached so far.
///
/// Read via `WorkflowRunner.progress`, a `ValueListenable` you can feed
/// straight into a `ValueListenableBuilder` (or bridge into a `StreamData` in
/// a `maac_mvvm` ViewModel) to drive a step indicator / progress bar UI.
class WorkflowProgress {
  /// The id of the step currently executing, or `null` if the workflow hasn't
  /// started yet or has already finished (successfully, failed, or cancelled).
  final String? currentStepId;

  /// Status of every step declared in `WorkflowRunner.steps`, keyed by step
  /// id. Steps not yet reached are [StepStatus.pending].
  final Map<String, StepStatus> stepStatuses;

  const WorkflowProgress({
    this.currentStepId,
    this.stepStatuses = const {},
  });

  /// The status of [stepId], or `null` if it isn't part of this workflow.
  StepStatus? statusOf(String stepId) => stepStatuses[stepId];

  WorkflowProgress copyWith({
    String? currentStepId,
    bool clearCurrentStepId = false,
    Map<String, StepStatus>? stepStatuses,
  }) {
    return WorkflowProgress(
      currentStepId: clearCurrentStepId ? null : (currentStepId ?? this.currentStepId),
      stepStatuses: stepStatuses ?? this.stepStatuses,
    );
  }
}
