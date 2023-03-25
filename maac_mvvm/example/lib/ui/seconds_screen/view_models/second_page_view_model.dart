import 'package:maac_mvvm/maac_mvvm.dart';

class SecondScreenViewModel extends ViewModel {
  SecondScreenViewModel();

  late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
    defaultValue: 0,
    viewModel: this,
  );

  StreamData<int> get uiState => _uiState;

  void increaseCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}
