import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/ui/app_life_state.dart';
import 'package:maac_mvvm/src/ui/awake_context.dart';
import 'package:maac_mvvm/src/view_model/view_model.dart';
import 'package:maac_mvvm/src/ui/base_state.dart';

abstract class ViewModelsWidget extends ViewStatefulWidget {
  const ViewModelsWidget({super.key});

  ///The [awake] method will be called immediately after the createViewModel method of ViewModelsWidget and before the onInitState method of
  ///the ViewModels.
  ///This will be helpful for setting up the necessary data.
  void awake(
    WrapperContext wrapperContext,
    List<ViewModel> viewModels,
  ) {}

  ///The [createViewModels] method is where you initialize the corresponding ViewModels.
  List<ViewModel> createViewModels();

  ///The [build] method is where you build the interface
  Widget build(BuildContext context, List<ViewModel> viewModels);

  @override
  // ignore:
  ViewState createState() => _BindViewModelsWidgetState();
}

abstract class ViewModelWidget<T extends ViewModel> extends ViewStatefulWidget {
  const ViewModelWidget({super.key});

  ///The [awake] method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of
  ///the ViewModel.
  ///This will be helpful for setting up the necessary data.
  void awake(
    WrapperContext wrapperContext,
    T viewModel,
  ) {}

  ///The [createViewModel] method is where you initialize the corresponding ViewModel.
  T createViewModel();

  ///The [build] method is where you build the interface
  Widget build(BuildContext context, T viewModel);

  @override
  // ignore:
  ViewState createState() => _BindViewModelWidgetState();
}

///Single Viewmodel state [ViewModelWidget]
class _BindViewModelWidgetState extends BaseViewModelState<ViewModelWidget> {
  @override
  List<ViewModel> bindViewModels() => [widget.createViewModel()];

  @override
  void aWake() {
    super.aWake();
    widget.awake(
      WrapperContext(context: context, lifeCycleManager: lifeCycleManager),
      viewModels.first,
    );
  }

  @override
  Widget get childBuilder => widget.build(context, viewModels.first);
}

///Multiple ViewModels state [ViewModelsWidget]
class _BindViewModelsWidgetState extends BaseViewModelState<ViewModelsWidget> {
  @override
  List<ViewModel> bindViewModels() => widget.createViewModels();

  @override
  void aWake() {
    super.aWake();
    widget.awake(
      WrapperContext(context: context, lifeCycleManager: lifeCycleManager),
      viewModels,
    );
  }

  @override
  Widget get childBuilder => widget.build(context, viewModels);
}
