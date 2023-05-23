import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

///A ViewModel class that is used with Riverpod and by default has a corresponding [UIState] [StateController]
///
/// ```dart
/// final _exampleUIStateProvider = StateProvider.autoDispose<ExamplePageUIState>((ref) {
///   return ExamplePageUIState();
/// });
///
/// final exampleViewModelProvider = Provider.autoDispose<ExamplePageViewModel>((ref) {
///   return ExamplePageViewModel(uiState: ref.watch(_exampleUIStateProvider.notifier));
/// });
///
/// class ExamplePageUIState {
///    int counter;
///
///    ExamplePageUIState({this.counter = 0});
///
///    ExamplePageUIState copyWith({int? counter}) {
///      return ExamplePageUIState(
///        counter: counter ?? this.counter,
///      );
///    }
/// }
///
/// class ExamplePageViewModel extends RiverViewModel<ExamplePageUIState> {
///   ExamplePageViewModel({required super.uiState});
///
///   final counterSelector = _exampleUIStateProvider.select((value) => value.counter);
///
///   void incrementCounter() {
///     uiState.update((state) => state.copyWith(counter: state.counter + 1));
///   }
/// }
/// ```
abstract class RiverViewModel<UISTate> extends ViewModel {
  final StateController<UISTate> _uiState;

  RiverViewModel({required StateController<UISTate> uiState})
      : _uiState = uiState;

  ///Getter returns the [StateController] used to update the UI state.
  StateController<UISTate> get uiState => _uiState;
}
