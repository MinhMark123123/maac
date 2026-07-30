/// Route paths for the signup wizard, nested under the `/signup` shell.
class SignupRoutes {
  SignupRoutes._();

  static const root = '/signup';
  static const basicInfo = '/signup/basic-info';
  static const loading = '/signup/loading';
  static const optionalDetails = '/signup/optional-details';
  static const review = '/signup/review';
  static const success = '/signup/success';
  static const failed = '/signup/failed';
}
