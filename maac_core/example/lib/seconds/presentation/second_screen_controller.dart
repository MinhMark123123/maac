import 'package:example/seconds/presentation/ui_state.dart';
import 'package:maac_core/maac_core.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'second_screen_controller.g.dart';

/*@riverpod
SecondScreenUIState _uiState(SecondScreenUIStateRef ref){
  return
}*/
@riverpod
SecondScreenController secondScreenController(SecondScreenControllerRef ref) {
  return SecondScreenController();
}

class SecondScreenController extends AppController {
  // final uiState = SecondScreenUIState();
  /*final StateController<SecondScreenUIState> uiState;

   SecondScreenController({required this.uiState});*/

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
