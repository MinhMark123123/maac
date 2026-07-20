import 'package:flutter/foundation.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'api_context.dart';
import 'api_steps.dart';

part 'sequential_api_view_model.g.dart';

/// Ordered (stepId, label) pairs matching the ids assembled in [SequentialApiViewModel.startFlow],
/// used to render the live step tracker in the UI regardless of decorator wrapping.
const apiStepDefinitions = [
  ('fetch_config', 'Config'),
  ('fetch_user_profile_timeout', 'Profile'),
  ('sync_data_retry', 'Sync'),
];

@BindableViewModel()
class SequentialApiViewModel extends ViewModel implements WorkflowListener<ApiContext> {
  @Bind()
  late final _workflowHistory = <String>[].mtd(this);

  @Bind()
  late final _isRunning = false.mtd(this);

  // Toggle Switches
  @Bind()
  late final _forceTimeout = false.mtd(this);

  @Bind()
  late final _forceSyncError = false.mtd(this);

  // Parameters
  int timeoutLimitSeconds = 3;
  int retryAttempts = 3;

  CancellationToken? _cancellationToken;
  late final ApiContext _context = ApiContext();

  // Reassigned to a fresh WorkflowRunner on every startFlow() call, so
  // stepProgress always reflects the most recently configured decorators
  // (timeoutLimitSeconds / retryAttempts can change between runs).
  WorkflowRunner<ApiContext>? _runner;
  final _idleProgress = ValueNotifier<WorkflowProgress>(const WorkflowProgress());

  /// Live per-step status for the step tracker UI. Falls back to an empty,
  /// all-pending snapshot before the first run.
  ValueListenable<WorkflowProgress> get stepProgress => _runner?.progress ?? _idleProgress;

  void logEvent(String msg) {
    final list = List<String>.from(_workflowHistory.data);
    list.add('[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $msg');
    _workflowHistory.postValue(list);
  }

  void clearLogs() {
    _workflowHistory.postValue([]);
  }

  void setForceTimeout(bool value) => _forceTimeout.postValue(value);

  void setForceSyncError(bool value) {
    _forceSyncError.postValue(value);
    _context.forceSyncFail = value;
  }

  void startFlow() async {
    _isRunning.postValue(true);
    clearLogs();
    logEvent('Initializing API Workflow Execution...');

    _cancellationToken = CancellationToken();
    _context.configFetched = false;
    _context.profileFetched = false;
    _context.dataSynced = false;
    _context.syncAttempts = 0;
    _context.forceProfileDelay = _forceTimeout.data;
    _context.forceSyncFail = _forceSyncError.data;

    // Dynamically assemble workflow engine runners to demonstrate composing decorators
    _runner = WorkflowRunner<ApiContext>(
      steps: [
        FetchConfigStep(this),
        // Profile Step wrapped in Timeout decorator
        TimeoutStepDecorator(
          step: FetchUserProfileStep(this),
          timeout: Duration(seconds: timeoutLimitSeconds),
        ),
        // Sync Step wrapped in Retry decorator
        RetryStepDecorator(
          step: SyncDataStep(this),
          maxAttempts: retryAttempts,
          initialDelay: const Duration(seconds: 1),
          backoffFactor: 1.5,
        ),
      ],
      listener: this,
    );

    final result = await _runner!.run(_context, cancellationToken: _cancellationToken);
    _isRunning.postValue(false);

    switch (result) {
      case WorkflowSuccess():
        logEvent('API SEQUENCE SUCCESS!');
        break;
      case WorkflowFailure(:final failedStepId, :final error):
        logEvent('API SEQUENCE FAILED at step "$failedStepId". Error: $error');
        break;
      case WorkflowCancelled():
        logEvent('API SEQUENCE CANCELLED by user.');
        break;
    }
  }

  void cancelWorkflow() {
    _cancellationToken?.cancel();
  }

  // --- WorkflowListener ---
  @override
  void onWorkflowStart(ApiContext context) => logEvent('[Engine] Workflow Start');
  @override
  void onStepStart(String stepId, ApiContext context) => logEvent('[Engine] Step Start: $stepId');
  @override
  void onStepSuccess(String stepId, ApiContext context) => logEvent('[Engine] Step Success: $stepId');
  @override
  void onStepSkip(String stepId, ApiContext context) => logEvent('[Engine] Step Skip: $stepId');
  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, ApiContext context) =>
      logEvent('[Engine] Step Failure: $stepId. Error: $error');
  @override
  void onStepRollbackStart(String stepId, ApiContext context) => logEvent('[Engine] Rollback Start: $stepId');
  @override
  void onStepRollbackSuccess(String stepId, ApiContext context) => logEvent('[Engine] Rollback Success: $stepId');
  @override
  void onStepRollbackFailure(String stepId, Object error, ApiContext context) =>
      logEvent('[Engine] Rollback Failure: $stepId. Error: $error');
  @override
  void onWorkflowSuccess(ApiContext context) => logEvent('[Engine] Workflow Finished: Success');
  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, ApiContext context) =>
      logEvent('[Engine] Workflow Finished: Failure');

  @override
  void onDispose() {
    _cancellationToken?.cancel();
    _runner?.dispose();
    _idleProgress.dispose();
    super.onDispose();
  }
}
