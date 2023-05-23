import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/ui/app_life_state.dart';
import 'package:maac_mvvm/src/view_model/view_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class ViewModelWidget<T extends ViewModel> extends ViewStatefulWidget {
  const ViewModelWidget({Key? key}) : super(key: key);

  ///The [awake] method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of
  ///the ViewModel.
  ///This will be helpful for setting up the necessary data.
  void awake(BuildContext context, T viewModel) {}

  ///The [createViewModel] method is where you initialize the corresponding ViewModel.
  T createViewModel(BuildContext context);

  ///The [build] method is where you build the interface
  Widget build(BuildContext context, T viewModel);

  @override
  // ignore:
  ViewState createState() => _BindViewModelWidgetState();
}

class _BindViewModelWidgetState extends ViewState<ViewModelWidget> {
  final _visibilityDetectorKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      key: _visibilityDetectorKey,
      child: widget.build(context, viewModels.first),
    );
  }

  @override
  List<ViewModel> bindViewModels(BuildContext context) => [widget.createViewModel(context)];

  @override
  void aWake() {
    super.aWake();
    widget.awake(context, viewModels.first);
  }

  @override
  void deactivate() {
    lifeCycleManager.onDeActive(widget);
    super.deactivate();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    lifeCycleManager.onVisibilityChanged(info, widget);
  }
}
