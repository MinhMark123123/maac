import 'package:example/global.dart';
import 'package:example/seconds_screen/presentation/ui_state.dart';
import 'package:maac_core/maac_core.dart';
import 'package:riverpod/riverpod.dart';

final _secondScreenUiStateProvider = StateProvider.autoDispose<SecondScreenUIState>((ref) {
  return SecondScreenUIState(
    navigation: ref.watch(navigationProvider),
  );
});
final secondScreenControllerProvider = Provider.autoDispose<SecondScreenController>((ref) {
  return SecondScreenController(
    uiState: ref.watch(_secondScreenUiStateProvider.notifier),
  );
});

class SecondScreenController extends AppController {
  AutoDisposeStateProvider get ui => _secondScreenUiStateProvider;
  final StateController<SecondScreenUIState> uiState;

  SecondScreenController({required this.uiState});

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

  void increaseCounter() {
    //uiState.counterProvider.state. = uiState.counterProvider.state +1;
  }
}
