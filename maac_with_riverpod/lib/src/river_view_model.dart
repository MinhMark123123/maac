import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_core/maac_core.dart';

abstract class RiverViewModel<UISTate> extends ViewModel {
  final StateController<UISTate> _uiState;

  RiverViewModel({required StateController<UISTate> uiState}) : _uiState = uiState;

  StateController<UISTate> get uiState => _uiState;
}
