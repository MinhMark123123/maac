import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import '../sequential_api_flow/sequential_api_view_model.dart';
import '../signup_flow/signup_view_model.dart';
import '../single_flight_flow/single_flight_view_model.dart';

/// Registers a fresh `ViewModel` factory per showcase page with GetIt.
/// `DependencyViewModelWidget` resolves these on `initState` and unregisters
/// them on dispose, so navigating back into a page always starts clean.
void registerViewModels() {
  registerViewModel(() => SignupViewModel());
  registerViewModel(() => SequentialApiViewModel());
  registerViewModel(() => SingleFlightViewModel());
}
