import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_with_get_it/src/src.dart';
import 'package:mockito/annotations.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'test_config.mocks.dart';

GetIt sl = GetIt.instance;

@GenerateNiceMocks([
  MockSpec<ExampleViewModel>(),
  MockSpec<ExampleSecondViewModel>(),
  MockSpec<LifeCycleManager>(),
  MockSpec<WrapperContext>(),
  MockSpec<StreamDataViewModel<int>>(),
])
void mockDi() {
  registerViewModel(() => MockExampleViewModel());
  registerViewModel(() => MockExampleSecondViewModel());
}

Future<void> setupTester({
  required WidgetTester tester,
  required Widget child,
}) async {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(MaterialApp(home: child));
  //wait for VisibilityDetectorWidget complete
  await tester.binding.delayed(
    VisibilityDetectorController.instance.updateInterval,
  );
}

class ExampleViewModel extends ViewModel {
  late final _uiState = 1.mutableData(this);

  StreamData<int> get uiState => _uiState;
}

class ExampleSecondViewModel extends ViewModel {
  late final _uiState = 2.mutableData(this);

  StreamData<int> get uiState => _uiState;
}

class DependencyViewModelWidgetTest extends DependencyViewModelWidget<MockExampleViewModel> {
  const DependencyViewModelWidgetTest({super.key});

  @override
  Widget build(BuildContext context, ExampleViewModel viewModel) {
    return const SizedBox.shrink();
  }
}

class DependencyViewModelsWidgetTest extends DependencyViewModelsWidget {
  const DependencyViewModelsWidgetTest({super.key});

  @override
  Widget build(BuildContext context, List<ViewModel> viewModels) {
    return const SizedBox.shrink();
  }

  @override
  List<ViewModel> createViewModels() => [
        injectViewModel<MockExampleViewModel>(),
        injectViewModel<MockExampleSecondViewModel>(),
      ];

  @override
  void registerViewModel(ViewModel viewModel) {
    if (viewModel is MockExampleViewModel) {
      GetIt.instance.registerSingleton(viewModel);
      return;
    }
    if (viewModel is MockExampleSecondViewModel) {
      GetIt.instance.registerSingleton(viewModel);
    }
  }

  @override
  void unRegisterViewModel(ViewModel viewModel) {
    if (viewModel is MockExampleViewModel) {
      GetIt.instance.unregister(instance: viewModel);
      return;
    }
    if (viewModel is MockExampleSecondViewModel) {
      GetIt.instance.unregister(instance: viewModel);
    }
  }
}
