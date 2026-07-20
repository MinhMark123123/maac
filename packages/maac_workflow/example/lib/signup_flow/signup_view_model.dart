import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'signup_context.dart';
import 'signup_steps.dart';

part 'signup_view_model.g.dart';

@BindableViewModel()
class SignupViewModel extends ViewModel implements WorkflowListener<SignupContext> {
  // Navigation / Wizard State
  @Bind()
  late final _activeScreen = SignupScreen.welcome.mtd(this);

  // Active Workflow step history list
  @Bind()
  late final _workflowHistory = <String>[].mtd(this);

  // Checkbox inputs
  @Bind()
  late final _needsOptional = false.mtd(this);

  @Bind()
  late final _forceFail = false.mtd(this);

  // Form Fields
  final emailController = TextEditingController(text: 'test@maac.com');
  final passwordController = TextEditingController(text: 'password123');
  final referralController = TextEditingController();
  String? selectedAvatar;

  // Workflow Core
  CancellationToken? _cancellationToken;
  Completer<void>? _stepCompleter;
  late final SignupContext _context = SignupContext();
  SignupContext get context => _context;

  late final _workflowRunner = WorkflowRunner<SignupContext>(
    steps: [
      BasicInfoStep(this),
      CreateAccountStep(this),
      OptionalDetailsStep(this),
      SubmitRegistrationStep(this),
    ],
    listener: this,
  );

  void logEvent(String msg) {
    final list = List<String>.from(_workflowHistory.data);
    list.add('[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $msg');
    _workflowHistory.postValue(list);
  }

  void clearLogs() {
    _workflowHistory.postValue([]);
  }

  void setWizardScreen(SignupScreen screen) {
    _activeScreen.postValue(screen);
  }

  Completer<void> createStepCompleter(CancellationToken token) {
    _stepCompleter = Completer<void>();
    token.onCancel(() {
      if (_stepCompleter != null && !_stepCompleter!.isCompleted) {
        _stepCompleter!.completeError(WorkflowCancelledException());
      }
    });
    return _stepCompleter!;
  }

  void startFlow() async {
    clearLogs();
    logEvent('Starting Signup Flow...');
    _cancellationToken = CancellationToken();

    // Populate current options
    _context.email = emailController.text;
    _context.password = passwordController.text;
    _context.needsOptionalDetails = _needsOptional.data;
    _context.forceRegisterFailure = _forceFail.data;
    _context.avatarUrl = selectedAvatar;
    _context.referralCode = referralController.text;
    _context.userId = null;
    _context.isRegistered = false;

    final result = await _workflowRunner.run(_context, cancellationToken: _cancellationToken);

    switch (result) {
      case WorkflowSuccess():
        logEvent('Flow finished with SUCCESS!');
        setWizardScreen(SignupScreen.success);
        break;
      case WorkflowFailure(:final failedStepId, :final error):
        logEvent('Flow finished with FAILURE on step "$failedStepId". Error: $error');
        setWizardScreen(SignupScreen.failed);
        break;
      case WorkflowCancelled():
        logEvent('Flow finished with CANCELLATION by the user.');
        setWizardScreen(SignupScreen.failed);
        break;
    }
  }

  void submitCurrentStep() {
    // Save UI fields back to context as the flow proceeds
    _context.email = emailController.text;
    _context.password = passwordController.text;
    _context.avatarUrl = selectedAvatar;
    _context.referralCode = referralController.text;
    _context.needsOptionalDetails = _needsOptional.data;
    _context.forceRegisterFailure = _forceFail.data;

    if (_stepCompleter != null && !_stepCompleter!.isCompleted) {
      _stepCompleter!.complete();
    }
  }

  void cancelWorkflow() {
    logEvent('Requesting cancellation via CancellationToken...');
    _cancellationToken?.cancel();
  }

  void reset() {
    _cancellationToken?.cancel();
    _stepCompleter = null;
    selectedAvatar = null;
    referralController.clear();
    setWizardScreen(SignupScreen.welcome);
    clearLogs();
  }

  void setNeedsOptional(bool value) => _needsOptional.postValue(value);

  void setForceFail(bool value) {
    _forceFail.postValue(value);
    _context.forceRegisterFailure = value;
  }

  // --- WorkflowListener implementation ---
  @override
  void onWorkflowStart(SignupContext context) => logEvent('[Engine] Workflow Started');
  @override
  void onStepStart(String stepId, SignupContext context) => logEvent('[Engine] Step Start: $stepId');
  @override
  void onStepSuccess(String stepId, SignupContext context) => logEvent('[Engine] Step Success: $stepId');
  @override
  void onStepSkip(String stepId, SignupContext context) => logEvent('[Engine] Step Skip: $stepId');
  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, SignupContext context) =>
      logEvent('[Engine] Step Failure: $stepId. Error: $error');
  @override
  void onStepRollbackStart(String stepId, SignupContext context) => logEvent('[Engine] Rollback Start: $stepId');
  @override
  void onStepRollbackSuccess(String stepId, SignupContext context) => logEvent('[Engine] Rollback Success: $stepId');
  @override
  void onStepRollbackFailure(String stepId, Object error, SignupContext context) =>
      logEvent('[Engine] Rollback Failure: $stepId. Error: $error');
  @override
  void onWorkflowSuccess(SignupContext context) => logEvent('[Engine] Workflow Finished: Success');
  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, SignupContext context) =>
      logEvent('[Engine] Workflow Finished: Failure');

  @override
  void onDispose() {
    _cancellationToken?.cancel();
    emailController.dispose();
    passwordController.dispose();
    referralController.dispose();
    super.onDispose();
  }
}
