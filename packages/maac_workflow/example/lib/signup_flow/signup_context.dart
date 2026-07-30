import 'package:maac_workflow/maac_workflow.dart';

/// Keys used to store signup wizard state in the shared [FlowContext].
abstract class SignupKeys {
  static const email = 'email';
  static const password = 'password';
  static const avatarUrl = 'avatarUrl';
  static const referralCode = 'referralCode';

  // Output / server-assigned state
  static const userId = 'userId';
  static const isRegistered = 'isRegistered';

  // Execution toggles configured in the UI
  static const needsOptionalDetails = 'needsOptionalDetails';
  static const forceRegisterFailure = 'forceRegisterFailure';
}

/// Typed, ergonomic dot-access over the raw [FlowContext] store — no
/// subclassing required, `FlowContext` itself stays a plain, reusable store
/// (see `packages/maac_workflow/lib/src/flow_context.dart`).
extension SignupContextX on FlowContext {
  String get email => read<String>(SignupKeys.email) ?? '';
  set email(String value) => write(SignupKeys.email, value);

  String get password => read<String>(SignupKeys.password) ?? '';
  set password(String value) => write(SignupKeys.password, value);

  String? get avatarUrl => read<String>(SignupKeys.avatarUrl);
  set avatarUrl(String? value) => write(SignupKeys.avatarUrl, value);

  String? get referralCode => read<String>(SignupKeys.referralCode);
  set referralCode(String? value) => write(SignupKeys.referralCode, value);

  String? get userId => read<String>(SignupKeys.userId);
  set userId(String? value) => write(SignupKeys.userId, value);

  bool get isRegistered => read<bool>(SignupKeys.isRegistered) ?? false;
  set isRegistered(bool value) => write(SignupKeys.isRegistered, value);

  bool get needsOptionalDetails => read<bool>(SignupKeys.needsOptionalDetails) ?? false;
  set needsOptionalDetails(bool value) => write(SignupKeys.needsOptionalDetails, value);

  bool get forceRegisterFailure => read<bool>(SignupKeys.forceRegisterFailure) ?? false;
  set forceRegisterFailure(bool value) => write(SignupKeys.forceRegisterFailure, value);
}
