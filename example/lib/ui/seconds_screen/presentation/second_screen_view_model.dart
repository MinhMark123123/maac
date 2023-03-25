import 'package:maac_with_riverpod/maac_with_riverpod.dart';

import 'ui_state.dart';

final _secondScreenUiStateProvider = StateProvider.autoDispose<SecondPageUIState>((ref) {
  return SecondPageUIState();
});
final secondScreenViewModelProvider = Provider.autoDispose<SecondScreenViewModel>((ref) {
  return SecondScreenViewModel(
    uiState: ref.watch(_secondScreenUiStateProvider.notifier),
  );
});

class SecondScreenViewModel extends RiverViewModel<SecondPageUIState> {
  SecondScreenViewModel({required super.uiState});

  AutoDisposeStateProvider<SecondPageUIState> get ui => _secondScreenUiStateProvider;

  ProviderListenable<int> get counterChange => ui.select((value) => value.counter);

  void increaseCounter() {
    final counter = uiState.state.counter;
    uiState.update((state) => state.copyWith(counter: counter + 1));
  }
}
