import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:mockito/annotations.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'mocker.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LifeCycleManager>(),
  MockSpec<LifecycleComponent>(),
  MockSpec<VisibilityInfo>(),
  MockSpec<WrapperContext>(),
  MockSpec<ViewModel>(),
  MockSpec<TestViewModel>(),
  MockSpec<StreamData<int>>(),
])
class TestViewModel extends ViewModel {
  void setUpData() {}
}

// A concrete implementation of ViewStatefulWidget for testing purposes
class TestViewStatefulWidget extends ViewStatefulWidget {
  final MockLifeCycleManager lifeCycleManager;

  const TestViewStatefulWidget({Key? key, required this.lifeCycleManager})
      : super(key: key);

  @override
  ViewState createState() => TestViewState();
}

// A concrete implementation of ViewState for testing purposes
class TestViewState extends ViewState<TestViewStatefulWidget> {
  @override
  List<ViewModel> bindViewModels() {
    return [MockViewModel()];
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  MockLifeCycleManager get lifeCycleManager {
    return widget.lifeCycleManager;
  }
}

// A concrete implementation of ViewModelWidget for testing
class TestViewModelWidget extends ViewModelWidget<MockTestViewModel> {
  final MockTestViewModel viewModel;

  const TestViewModelWidget(this.viewModel, {super.key});

  @override
  MockTestViewModel createViewModel() => viewModel;

  @override
  void awake(WrapperContext context, MockTestViewModel viewModel) {
    super.awake(context, viewModel);
    viewModel.setUpData();
  }

  @override
  Widget build(BuildContext context, MockTestViewModel viewModel) {
    return Text('ViewModel: ${viewModel.hashCode}');
  }
}

// A concrete implementation of ViewModelsWidget for testing
class TestViewModelsWidget extends ViewModelsWidget {
  final List<MockTestViewModel> viewModels;

  const TestViewModelsWidget(this.viewModels, {super.key});

  @override
  List<ViewModel> createViewModels() => viewModels;

  @override
  void awake(WrapperContext context, List<ViewModel> viewModels) {
    super.awake(context, viewModels);
    for (var vm in (viewModels as List<MockTestViewModel>)) {
      vm.setUpData();
    }
  }

  @override
  Widget build(BuildContext context, List<ViewModel> viewModels) {
    return Column(
      children: [
        Text('ViewModel 1: ${viewModels[0].hashCode}'),
        Text('ViewModel 2: ${viewModels[1].hashCode}'),
      ],
    );
  }
}

Widget mockStreamWidget(StreamData<int> mockStream,
    {bool Function(int value)? useCache}) {
  return StreamDataConsumer<int>(
    streamData: mockStream,
    builder: (context, data, child) {
      if (useCache != null && useCache.call(data) && child != null) {
        return child;
      }
      return Text('Value: $data', textDirection: TextDirection.ltr);
    },
  );
}
