import 'package:get_it/get_it.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

final _sl = GetIt.asNewInstance();
var injectViewModel = _sl;

Future<void> resetViewModelSL() => _sl.reset();

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
  return _sl.get<T>(
    param1: param1,
    param2: param2,
    instanceName: instanceName,
    type: type,
  );
}
