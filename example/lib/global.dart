import 'package:example/main.dart';
import 'package:example/navigation/app_navigate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maac_core/maac_core.dart';

final navigationProvider = Provider<DelegateNavigation>((ref) {
  return AppNavigate(context: ref.read(routeContextDelegateProvider));
});
