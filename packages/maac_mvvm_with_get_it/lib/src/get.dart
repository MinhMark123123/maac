import 'package:get_it/get_it.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

final _sl = GetIt.asNewInstance();

/// create viewmodel instance from [registerViewModel] by _sl.get<T extends ViewModel>
var injectViewModel = _sl;

Future<void> resetViewModelSL() => _sl.reset();

/// register viewmodel instance to [GetIt] with [_sl] custom instance
void registerViewModel<T extends ViewModel>(
  T Function() factoryFunc, {
  String? instanceName,
}) {
  _sl.registerFactory(factoryFunc, instanceName: instanceName);
}

T getViewModel<T extends ViewModel>({
  dynamic param1,
  dynamic param2,
  String? instanceName,
  Type? type,
}) {
  return GetIt.instance.get<T>(
    param1: param1,
    param2: param2,
    instanceName: instanceName,
    type: type,
  );
}
