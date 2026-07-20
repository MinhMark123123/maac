import 'package:maac_workflow/maac_workflow.dart';

import 'signup_context.dart';
import 'signup_view_model.dart';

/// Interactive Step 1: Basic Info
class BasicInfoStep extends WorkflowStep<SignupContext> {
  final SignupViewModel viewModel;
  BasicInfoStep(this.viewModel);

  @override
  String get id => 'basic_info';

  @override
  String get description => 'Interactive Form: Fill in Email & Password';

  @override
  Future<StepResult<void>> execute(SignupContext context, CancellationToken token) async {
    viewModel.logEvent('Step 1 [Basic Info]: Showing basic details screen...');
    viewModel.setWizardScreen(SignupScreen.basicInfo);

    // Create a completer for the user to proceed by hitting "Next"
    final completer = viewModel.createStepCompleter(token);
    await completer.future;

    token.throwIfCancelled();
    viewModel.logEvent('Step 1 [Basic Info]: Completed. Email: ${context.email}');
    return const StepSuccess(null);
  }
}

/// Background Step 2: Create Account API (Simulating a database record creation)
class CreateAccountStep extends WorkflowStep<SignupContext> {
  final SignupViewModel viewModel;
  CreateAccountStep(this.viewModel);

  @override
  String get id => 'create_account_api';

  @override
  String get description => 'Background API: Provisioning User ID on server';

  @override
  Future<StepResult<void>> execute(SignupContext context, CancellationToken token) async {
    viewModel.logEvent('Step 2 [Create Account API]: Call database to provision user account...');
    viewModel.setWizardScreen(SignupScreen.loadingBackend);

    // Simulate API delay
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      token.throwIfCancelled();
    }

    context.userId = 'usr_mock_${DateTime.now().millisecondsSinceEpoch % 100000}';
    viewModel.logEvent('Step 2 [Create Account API]: Success. Assigned ID: ${context.userId}');
    return const StepSuccess(null);
  }

  @override
  Future<void> rollback(SignupContext context) async {
    viewModel.logEvent('Rollback [Create Account API]: Deleting provisioned account ${context.userId} from server database...');
    // Simulate cleanup delay
    await Future.delayed(const Duration(milliseconds: 1000));
    context.userId = null;
    viewModel.logEvent('Rollback [Create Account API]: Cleanup successful.');
  }
}

/// Interactive Step 3: Optional details (Avatar selection and referral code)
class OptionalDetailsStep extends WorkflowStep<SignupContext> {
  final SignupViewModel viewModel;
  OptionalDetailsStep(this.viewModel);

  @override
  String get id => 'optional_details';

  @override
  String get description => 'Interactive Form (Conditional): Choose Avatar & Referral';

  @override
  Future<bool> canRun(SignupContext context) async {
    return context.needsOptionalDetails;
  }

  @override
  Future<StepResult<void>> execute(SignupContext context, CancellationToken token) async {
    viewModel.logEvent('Step 3 [Optional Details]: Showing avatar & referral screen...');
    viewModel.setWizardScreen(SignupScreen.optionalDetails);

    final completer = viewModel.createStepCompleter(token);
    await completer.future;

    token.throwIfCancelled();
    viewModel.logEvent('Step 3 [Optional Details]: Completed. Avatar: ${context.avatarUrl ?? "None"}, Referral: ${context.referralCode ?? "None"}');
    return const StepSuccess(null);
  }
}

/// Interactive Step 4: Final Review and Submission
class SubmitRegistrationStep extends WorkflowStep<SignupContext> {
  final SignupViewModel viewModel;
  SubmitRegistrationStep(this.viewModel);

  @override
  String get id => 'submit_registration';

  @override
  String get description => 'Interactive Form: Final Review & Publish';

  @override
  Future<StepResult<void>> execute(SignupContext context, CancellationToken token) async {
    viewModel.logEvent('Step 4 [Submit Registration]: Showing review screen...');
    viewModel.setWizardScreen(SignupScreen.reviewScreen);

    final completer = viewModel.createStepCompleter(token);
    await completer.future;

    token.throwIfCancelled();
    viewModel.setWizardScreen(SignupScreen.loadingBackend);
    viewModel.logEvent('Step 4 [Submit Registration]: Submitting final configuration...');

    // Simulate final API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    token.throwIfCancelled();

    if (context.forceRegisterFailure) {
      viewModel.logEvent('Step 4 [Submit Registration]: Forced Error Triggered! Failed to finalize registration.');
      return StepFailure(Exception('Failed to finalize registration (forced API error).'));
    }

    context.isRegistered = true;
    viewModel.logEvent('Step 4 [Submit Registration]: Finished successfully!');
    return const StepSuccess(null);
  }
}
