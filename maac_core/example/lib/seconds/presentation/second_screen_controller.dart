import 'package:maac_core/maac_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'second_screen_controller.g.dart';

@riverpod
SecondScreenController secondScreenController(SecondScreenControllerRef ref) {
  return SecondScreenController();
}

class SecondScreenController extends AppController {
  // final uiState = SecondScreenUIState();

  @override
  void onInitState() {
    super.onInitState();
  }

  @override
  void onDispose() {
    super.onDispose();
  }

  void increaseCounter() {
    //uiState.counterProvider.state. = uiState.counterProvider.state +1;
  }
}
