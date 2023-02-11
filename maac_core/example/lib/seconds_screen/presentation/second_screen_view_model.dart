import 'package:maac_core/maac_core.dart';

class SecondScreenViewModel extends ViewModel {
  late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
    defaultValue: 0,
    viewModel: this,
  );

  StreamData<int> get uiState => _uiState;

  SecondScreenViewModel() ;

  void increaseCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}
