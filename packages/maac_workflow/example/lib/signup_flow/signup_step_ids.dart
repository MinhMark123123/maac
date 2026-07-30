/// Step id constants, shared between `signup_steps.dart` (each step's `id`
/// getter) and the page ViewModels (`workflowRunner.submit(...)` calls), so
/// the two sides can't silently drift out of sync.
abstract class SignupStepIds {
  static const basicInfo = 'basic_info';
  static const createAccountApi = 'create_account_api';
  static const optionalDetails = 'optional_details';
  static const submitRegistration = 'submit_registration';
}
