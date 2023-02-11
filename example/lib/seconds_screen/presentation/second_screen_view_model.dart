import 'package:example/global.dart';
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

  SecondScreenViewModel({required this.uiState}) {
    print("SecondScreenViewModel constructor");
  }

  @override
  bool enableBindAppLifeCycle() => true;

  @override
  void onInitState() {
    super.onInitState();
    print("on init state");
  }

  @override
  void onDispose() {
    super.onDispose();
    print("on onDispose");
  }

  @override
  void onResumed() {
    print("on onResumed");
    super.onResumed();
  }

  @override
  void onReady() {
    print("on ready");
    super.onReady();
  }

  @override
  void onInactive() {
    print("on onInactive");
    super.onInactive();
  }

  @override
  void onPaused() {
    print("on onPaused");
    super.onPaused();
  }

  @override
  void onDetached() {
    print("on onDetached");
    super.onDetached();
  }

  void increaseCounter() {
    final counter = uiState.state.counter;
    uiState.update((state) => state.copyWith(counter: counter + 1));
  }
}
