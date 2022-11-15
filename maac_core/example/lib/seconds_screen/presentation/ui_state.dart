/*
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SecondScreenUIState {
  final counterProvider = StateProvider.autoDispose<int>((ref) {
    return 0;
  });
  StateController<int> get counter => counterProvider.state;
}
*/

import 'package:maac_core/maac_core.dart';

class SecondScreenUIState extends UIState {
  SecondScreenUIState({
    required super.navigation,
  });

  int counter = 0;

  SecondScreenUIState copyWith({int? counter}) {
    return SecondScreenUIState(
      navigation: navigation,
    )..counter = counter ?? this.counter;
  }
}
