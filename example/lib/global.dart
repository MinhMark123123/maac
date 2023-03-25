import 'package:example/main.dart';
import 'package:example/navigation/app_navigate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

final navigationProvider = Provider<DelegateNavigation>((ref) {
  return AppNavigate(context: ref.read(routeContextDelegateProvider));
});
