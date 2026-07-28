import 'dart:async';

import 'package:maac_workflow/maac_workflow.dart';

import '../common/callbacks.dart';
import '../data/auth_repository.dart';
import 'signup_context.dart';
import 'signup_routes.dart';
import 'signup_step_ids.dart';

/// Interactive Step 1: Basic Info
class BasicInfoStep extends InteractiveStep<FlowContext, Object?> {
  final LogEvent logEvent;
  final Navigate navigateTo;
  BasicInfoStep({required this.logEvent, required this.navigateTo});

  @override
  String get id => SignupStepIds.basicInfo;

  @override
  String get description => 'Interactive Form: Fill in Email & Password';

  @override
  void onActivate(FlowContext context, CancellationToken token) {
    logEvent('Step 1 [Basic Info]: Showing basic details screen...');
    navigateTo(SignupRoutes.basicInfo);
  }

  @override
  StepResult onSubmit(FlowContext context, Object? input, CancellationToken token) {
    logEvent('Step 1 [Basic Info]: Completed. Email: ${context.email}');
    return const StepSuccess();
  }
}

/// Interactive Step 3: Optional details (Avatar selection and referral code)
class OptionalDetailsStep extends InteractiveStep<FlowContext, Object?> {
  final LogEvent logEvent;
  final Navigate navigateTo;
  OptionalDetailsStep({required this.logEvent, required this.navigateTo});

  @override
  String get id => SignupStepIds.optionalDetails;

  @override
  String get description => 'Interactive Form (Conditional): Choose Avatar & Referral';

  @override
  Future<bool> canRun(FlowContext context) async {
    return context.needsOptionalDetails;
  }

  @override
  void onActivate(FlowContext context, CancellationToken token) {
    logEvent('Step 3 [Optional Details]: Showing avatar & referral screen...');
    navigateTo(SignupRoutes.optionalDetails);
  }

  @override
  StepResult onSubmit(FlowContext context, Object? input, CancellationToken token) {
    logEvent(
      'Step 3 [Optional Details]: Completed. Avatar: ${context.avatarUrl ?? "None"}, Referral: ${context.referralCode ?? "None"}',
    );
    return const StepSuccess();
  }
}

/// Interactive Step 4: Final Review and Submission
class SubmitRegistrationStep extends InteractiveStep<FlowContext, Object?> {
  final LogEvent logEvent;
  final Navigate navigateTo;
  final AuthRepository authRepository;
  SubmitRegistrationStep({required this.logEvent, required this.navigateTo, required this.authRepository});

  @override
  String get id => SignupStepIds.submitRegistration;

  @override
  String get description => 'Interactive Form: Final Review & Publish';

  @override
  void onActivate(FlowContext context, CancellationToken token) {
    logEvent('Step 4 [Submit Registration]: Showing review screen...');
    navigateTo(SignupRoutes.review);
  }

  @override
  Future<StepResult> onSubmit(FlowContext context, Object? input, CancellationToken token) async {
    navigateTo(SignupRoutes.loading);
    logEvent('Step 4 [Submit Registration]: Submitting final configuration...');

    try {
      await authRepository.finalizeRegistration(forceFail: context.forceRegisterFailure);
    } catch (e, stack) {
      token.throwIfCancelled();
      logEvent('Step 4 [Submit Registration]: Forced Error Triggered! Failed to finalize registration.');
      return StepFailure(e, stack);
    }
    token.throwIfCancelled();

    context.isRegistered = true;
    logEvent('Step 4 [Submit Registration]: Finished successfully!');
    return const StepSuccess();
  }
}
