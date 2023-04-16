import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

abstract class DependencyViewModelWidget<T extends ViewModel>
    extends ViewModelWidget<T> {
  const DependencyViewModelWidget({super.key});

  @override
  // ignore:
  ViewState createState() => _BindViewModelWidgetState<T>();

  ///Supports setting up [mockViewModel] for the widget in the case of UI testing.
  ///After calling this method, the corresponding widget will prioritize using the passed-in mockViewModel.
  ///
  ///For example:
  ///
  /// ```dart
  /// final mockStream = MockStreamDataViewModel();
  /// final mockViewModel = MockExamplePageViewModel();
  /// when(mockViewModel.uiState).thenAnswer((_) => mockStream);
  /// when(mockStream.data).thenReturn(1);
  /// await tester.pumpWidget(const MaterialApp(home: exampleApp));
  /// await tester.binding.delayed(VisibilityDetectorController.instance.updateInterval);
  /// ```
  @visibleForTesting
  void setupMockViewModel(T mockViewModel) {
    return GetIt.instance.registerFactory<T>(() => mockViewModel);
  }
}

class _BindViewModelWidgetState<T extends ViewModel>
    extends ViewState<DependencyViewModelWidget> {
  final _visibilityDetectorKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      key: _visibilityDetectorKey,
      child: widget.build(context, GetIt.instance.get<T>()),
    );
  }

  @override
  List<ViewModel> bindViewModels(BuildContext context) =>
      [widget.createViewModel(context)];

  @override
  void aWake() {
    if (!Platform.environment.containsKey('FLUTTER_TEST') &&
        !GetIt.instance.isRegistered<T>()) {
      GetIt.instance.registerFactory<T>(() => viewModels.first as T);
    }
    super.aWake();
    widget.awake(context, GetIt.instance.get<T>());
  }

  @override
  void deactivate() {
    lifeCycleManager.onDeActive(widget);
    super.deactivate();
  }

  @override
  void dispose() {
    GetIt.instance.unregister<T>();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    lifeCycleManager.onVisibilityChanged(info, widget);
  }
}
