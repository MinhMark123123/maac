import 'package:maac_mvvm/maac_mvvm.dart';

extension StreamDataViewModelExtensionGeneric<T> on T {
  StreamDataViewModel<T> mutableData(ViewModel viewModel) {
    return StreamDataViewModel<T>(
      defaultValue: this,
      viewModel: viewModel,
    );
  }

  ///shorten name
  StreamDataViewModel<T> mtd(ViewModel viewModel) {
    return StreamDataViewModel<T>(
      defaultValue: this,
      viewModel: viewModel,
    );
  }
}

extension StreamDataExtension<T> on StreamDataViewModel<T> {
  StreamData<T> get streamData => this;
}
