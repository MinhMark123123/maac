import 'package:example/seconds_screen/presentation/ui_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_core/maac_core.dart';

final _secondScreenUiStateProvider = StateProvider.autoDispose<SecondScreenUIState>((ref) {
  return SecondScreenUIState();
});
final secondScreenControllerProvider = Provider.autoDispose<SecondScreenViewModel>((ref) {
  return SecondScreenViewModel(
    uiState: ref.watch(_secondScreenUiStateProvider.notifier),
  );
});

class SecondScreenViewModel extends ViewModel {
  AutoDisposeStateProvider<SecondScreenUIState> get ui => _secondScreenUiStateProvider;

  ProviderListenable<int> get counterChange => ui.select((value) => value.counter);

  final StateController<SecondScreenUIState> uiState;

  SecondScreenViewModel({required this.uiState});

  @override
  bool enableBindAppLifeCycle() => true;

  void increaseCounter() {
    final counter = uiState.state.counter;
    uiState.update((state) => state.copyWith(counter: counter + 1));
  }

  @override
  void onResume() {
    super.onResume();
  }

  @override
  void onPause() {
    super.onPause();
  }
}
