/// Shared state that flows through every step of the signup wizard.
class SignupContext {
  String email = '';
  String password = '';
  String? avatarUrl;
  String? referralCode;

  // Output / server-assigned states
  String? userId;
  bool isRegistered = false;

  // Execution toggles configured in the UI
  bool needsOptionalDetails = false;
  bool forceRegisterFailure = false;
}

/// UI screens the signup wizard steps navigate between.
enum SignupScreen {
  welcome,
  basicInfo,
  loadingBackend,
  optionalDetails,
  reviewScreen,
  success,
  failed,
}
