import 'package:go_router/go_router.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../common/logging_view_model.dart';
import '../data/auth_repository.dart';
import 'signup_context.dart';
import 'signup_routes.dart';
import 'signup_step_ids.dart';
import 'signup_steps.dart';

part 'signup_flow_view_model.g.dart';

/// Ordered (stepId, label) pairs matching the ids assembled in
/// [SignupFlowViewModel.workflowRunner], used to render the step indicator
/// in [SignupFlowShell] regardless of which step page is currently mounted.
const signupStepDefinitions = [
  (SignupStepIds.basicInfo, 'Basic Info'),
  (SignupStepIds.createAccountApi, 'Create Account'),
  (SignupStepIds.optionalDetails, 'Optional'),
  (SignupStepIds.submitRegistration, 'Review & Submit'),
];

/// Coordinator for the whole signup wizard: owns the [WorkflowRunner], the
/// shared [FlowContext], and the [GoRouter] navigation triggered from
/// inside step callbacks. Lives as long as `/signup` and its nested step
/// routes are mounted (resolved once by `SignupFlowShell`), so it survives
/// navigation between individual step pages.
@BindableViewModel()
class SignupFlowViewModel extends LoggingViewModel {
  // Checkbox inputs, shared between the welcome and review screens
  @Bind()
  late final _needsOptional = false.mtd(this);

  @Bind()
  late final _forceFail = false.mtd(this);

  // Workflow Core
  GoRouter? _router;
  CancellationToken? _cancellationToken;
  late final FlowContext _context = FlowContext();
  FlowContext get context => _context;

  final authRepository = AuthRepository();

  late final WorkflowRunner<FlowContext> workflowRunner = WorkflowRunner<FlowContext>(
    steps: [
      BasicInfoStep(logEvent: logEvent, navigateTo: navigateTo),
      WorkflowStep<FlowContext>.action(
        id: SignupStepIds.createAccountApi,
        description: 'Background API: Provisioning User ID on server',
        execute: (ctx, token) async {
          logEvent('Step 2 [Create Account API]: Call database to provision user account...');
          navigateTo(SignupRoutes.loading);

          ctx.userId = await authRepository.createAccount(ctx.email, ctx.password);
          token.throwIfCancelled();
          logEvent('Step 2 [Create Account API]: Success. Assigned ID: ${ctx.userId}');
          return const StepSuccess();
        },
        rollback: (ctx) async {
          logEvent('Rollback [Create Account API]: Deleting provisioned account ${ctx.userId} from server database...');
          await authRepository.deleteAccount(ctx.userId!);
          ctx.userId = null;
          logEvent('Rollback [Create Account API]: Cleanup successful.');
        },
      ),
      OptionalDetailsStep(logEvent: logEvent, navigateTo: navigateTo),
      SubmitRegistrationStep(logEvent: logEvent, navigateTo: navigateTo, authRepository: authRepository),
    ],
  );

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void navigateTo(String location) {
    _router?.go(location);
  }

  void startFlow() async {
    clearLogs();
    logEvent('Starting Signup Flow...');
    _cancellationToken = CancellationToken();

    _context.needsOptionalDetails = _needsOptional.data;
    _context.forceRegisterFailure = _forceFail.data;
    _context.userId = null;
    _context.isRegistered = false;

    final result = await workflowRunner.run(_context, cancellationToken: _cancellationToken);

    switch (result) {
      case WorkflowSuccess():
        logEvent('Flow finished with SUCCESS!');
        navigateTo(SignupRoutes.success);
        break;
      case WorkflowFailure(:final failedStepId, :final error):
        logEvent('Flow finished with FAILURE on step "$failedStepId". Error: $error');
        navigateTo(SignupRoutes.failed);
        break;
      case WorkflowCancelled():
        logEvent('Flow finished with CANCELLATION by the user.');
        navigateTo(SignupRoutes.failed);
        break;
    }
  }

  void cancelWorkflow() {
    logEvent('Requesting cancellation via CancellationToken...');
    _cancellationToken?.cancel();
  }

  void reset() {
    _cancellationToken?.cancel();
    clearLogs();
    navigateTo(SignupRoutes.root);
  }

  void setNeedsOptional(bool value) => _needsOptional.postValue(value);

  void setForceFail(bool value) {
    _forceFail.postValue(value);
    _context.forceRegisterFailure = value;
  }

  @override
  void onDispose() {
    _cancellationToken?.cancel();
    workflowRunner.dispose();
    super.onDispose();
  }
}
