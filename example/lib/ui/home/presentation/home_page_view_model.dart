import 'package:maac_core/maac_core.dart';
import 'package:maac_with_riverpod/maac_with_riverpod.dart';

final homePageViewModelProvider = Provider.autoDispose<HomePageViewModel>((ref) {
  return HomePageViewModel();
});

class HomePageViewModel extends ViewModel {}
