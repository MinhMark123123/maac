

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

final homePageViewModelProvider = Provider.autoDispose<HomePageViewModel>((ref) {
  return HomePageViewModel();
});

class HomePageViewModel extends ViewModel {}
