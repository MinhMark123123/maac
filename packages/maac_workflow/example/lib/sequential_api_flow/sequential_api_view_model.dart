import 'package:flutter/foundation.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../common/logging_view_model.dart';
import '../common/logging_workflow_listener.dart';
import '../data/api_repository.dart';
import 'api_context.dart';
import 'api_steps.dart';

part 'sequential_api_view_model.g.dart';

/// Ordered (stepId, label) pairs matching the ids assembled in [SequentialApiViewModel.startFlow],
/// used to render the live step tracker in the UI regardless of decorator wrapping.
const apiStepDefinitions = [('fetch_config', 'Config'), ('fetch_user_profile_timeout', 'Profile'), ('sync_data_retry', 'Sync')];

@BindableViewModel()
class SequentialApiViewModel extends LoggingViewModel {
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

  final apiRepository = ApiRepository();

  late final _apiListener = LoggingWorkflowListener<ApiContext>(prefix: '[Config/Sync]', logEvent: logEvent);

  // Reassigned to a fresh WorkflowRunner on every startFlow() call, so
  // stepProgress always reflects the most recently configured decorators
  // (timeoutLimitSeconds / retryAttempts can change between runs).
  WorkflowRunner<ApiContext>? _runner;
  final _idleProgress = ValueNotifier<WorkflowProgress>(const WorkflowProgress());

  /// Live per-step status for the step tracker UI. Falls back to an empty,
  /// all-pending snapshot before the first run.
  ValueListenable<WorkflowProgress> get stepProgress => _runner?.progress ?? _idleProgress;

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
    _context.config = null;
    _context.profile = null;
    _context.syncReport = null;
    _context.syncAttempts = 0;
    _context.forceProfileDelay = _forceTimeout.data;
    _context.forceSyncFail = _forceSyncError.data;

    // Dynamically assemble workflow engine runners to demonstrate composing decorators
    _runner = WorkflowRunner<ApiContext>(
      steps: [
        FetchConfigStep(logEvent: logEvent, apiRepository: apiRepository),
        // Profile Step wrapped in Timeout decorator
        TimeoutStepDecorator(
          step: FetchUserProfileStep(logEvent: logEvent, apiRepository: apiRepository),
          timeout: Duration(seconds: timeoutLimitSeconds),
        ),
        // Sync Step wrapped in Retry decorator
        RetryStepDecorator(
          step: SyncDataStep(logEvent: logEvent, apiRepository: apiRepository),
          maxAttempts: retryAttempts,
          initialDelay: const Duration(seconds: 1),
          backoffFactor: 1.5,
        ),
      ],
      listener: _apiListener,
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

  @override
  void onDispose() {
    _cancellationToken?.cancel();
    _runner?.dispose();
    _idleProgress.dispose();
    super.onDispose();
  }
}
