import 'package:flutter/foundation.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'api_context.dart';
import 'api_steps.dart';
import 'notification_context.dart';
import 'notification_step.dart';

part 'sequential_api_view_model.g.dart';

/// Ordered (stepId, label) pairs matching the ids assembled in [SequentialApiViewModel.startFlow],
/// used to render the live step tracker in the UI regardless of decorator wrapping.
const apiStepDefinitions = [
  ('fetch_config', 'Config'),
  ('fetch_user_profile_timeout', 'Profile'),
  ('sync_data_retry', 'Sync'),
];

@BindableViewModel()
class SequentialApiViewModel extends ViewModel {
  @Bind()
  late final _workflowHistory = <String>[].mtd(this);

  @Bind()
  late final _isRunning = false.mtd(this);

  // Toggle Switches
  @Bind()
  late final _forceTimeout = false.mtd(this);

  @Bind()
  late final _forceSyncError = false.mtd(this);

  @Bind()
  late final _forceDenyPermission = false.mtd(this);

  // Parameters
  int timeoutLimitSeconds = 3;
  int retryAttempts = 3;

  CancellationToken? _cancellationToken;
  late final ApiContext _context = ApiContext();
  late final NotificationPermissionContext _notificationContext = NotificationPermissionContext();

  // Adapters, not `implements WorkflowListener<T>` on the ViewModel itself —
  // that would make it impossible to also listen to _notificationRunner below,
  // since a class can't implement the same generic interface twice with two
  // different type arguments (WorkflowListener<ApiContext> vs
  // WorkflowListener<NotificationPermissionContext>).
  late final _apiListener = ApiWorkflowListener(this);
  late final _notificationListener = NotificationWorkflowListener(this);

  // Reassigned to a fresh WorkflowRunner on every startFlow() call, so
  // stepProgress always reflects the most recently configured decorators
  // (timeoutLimitSeconds / retryAttempts can change between runs).
  WorkflowRunner<ApiContext>? _runner;
  final _idleProgress = ValueNotifier<WorkflowProgress>(const WorkflowProgress());

  /// Live per-step status for the step tracker UI. Falls back to an empty,
  /// all-pending snapshot before the first run.
  ValueListenable<WorkflowProgress> get stepProgress => _runner?.progress ?? _idleProgress;

  // A second, independent WorkflowRunner on the same screen, over a
  // completely different TContext — proves multiple runners coexist fine
  // once the ViewModel isn't itself the (single) WorkflowListener.
  WorkflowRunner<NotificationPermissionContext>? _notificationRunner;
  final _idleNotificationProgress = ValueNotifier<WorkflowProgress>(const WorkflowProgress());

  ValueListenable<WorkflowProgress> get notificationProgress => _notificationRunner?.progress ?? _idleNotificationProgress;

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

  void setForceDenyPermission(bool value) {
    _forceDenyPermission.postValue(value);
    _notificationContext.forceDeny = value;
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

  void requestNotificationPermission() async {
    _notificationContext.granted = false;
    _notificationContext.forceDeny = _forceDenyPermission.data;

    _notificationRunner = WorkflowRunner<NotificationPermissionContext>(
      steps: [RequestNotificationPermissionStep(this)],
      listener: _notificationListener,
    );

    await _notificationRunner!.run(_notificationContext);
  }

  @override
  void onDispose() {
    _cancellationToken?.cancel();
    _runner?.dispose();
    _idleProgress.dispose();
    _notificationRunner?.dispose();
    _idleNotificationProgress.dispose();
    super.onDispose();
  }
}

/// Forwards `WorkflowListener<ApiContext>` callbacks to plain methods on
/// [SequentialApiViewModel], logging under its own `[Config/Sync]` prefix.
class ApiWorkflowListener extends WorkflowListener<ApiContext> {
  final SequentialApiViewModel viewModel;
  ApiWorkflowListener(this.viewModel);

  @override
  void onWorkflowStart(ApiContext context) => viewModel.logEvent('[Config/Sync] Workflow Start');
  @override
  void onStepStart(String stepId, ApiContext context) => viewModel.logEvent('[Config/Sync] Step Start: $stepId');
  @override
  void onStepSuccess(String stepId, ApiContext context) => viewModel.logEvent('[Config/Sync] Step Success: $stepId');
  @override
  void onStepSkip(String stepId, ApiContext context) => viewModel.logEvent('[Config/Sync] Step Skip: $stepId');
  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, ApiContext context) =>
      viewModel.logEvent('[Config/Sync] Step Failure: $stepId. Error: $error');
  @override
  void onStepRollbackStart(String stepId, ApiContext context) => viewModel.logEvent('[Config/Sync] Rollback Start: $stepId');
  @override
  void onStepRollbackSuccess(String stepId, ApiContext context) => viewModel.logEvent('[Config/Sync] Rollback Success: $stepId');
  @override
  void onStepRollbackFailure(String stepId, Object error, ApiContext context) =>
      viewModel.logEvent('[Config/Sync] Rollback Failure: $stepId. Error: $error');
  @override
  void onWorkflowSuccess(ApiContext context) => viewModel.logEvent('[Config/Sync] Workflow Finished: Success');
  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, ApiContext context) =>
      viewModel.logEvent('[Config/Sync] Workflow Finished: Failure');
}

/// Forwards `WorkflowListener<NotificationPermissionContext>` callbacks to
/// plain methods on [SequentialApiViewModel], logging under its own
/// `[Notifications]` prefix. A distinct class from [ApiWorkflowListener]
/// because its `TContext` is different — this is exactly the pattern that
/// lets one ViewModel drive multiple `WorkflowRunner`s without itself
/// `implements`-ing `WorkflowListener` for any of them.
class NotificationWorkflowListener extends WorkflowListener<NotificationPermissionContext> {
  final SequentialApiViewModel viewModel;
  NotificationWorkflowListener(this.viewModel);

  @override
  void onWorkflowStart(NotificationPermissionContext context) => viewModel.logEvent('[Notifications] Workflow Start');
  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, NotificationPermissionContext context) =>
      viewModel.logEvent('[Notifications] Step Failure: $stepId. Error: $error');
  @override
  void onWorkflowSuccess(NotificationPermissionContext context) => viewModel.logEvent('[Notifications] Workflow Finished: Success');
  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, NotificationPermissionContext context) =>
      viewModel.logEvent('[Notifications] Workflow Finished: Failure');
}
