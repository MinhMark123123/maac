import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/ui/app_life_state.dart';
import 'package:maac_mvvm/src/view_model/view_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class ViewModelWidget<T extends ViewModel> extends ViewStatefulWidget {
  const ViewModelWidget({Key? key}) : super(key: key);

  Widget build(BuildContext context, T viewModel);

  T createViewModel(BuildContext context);

  void awake(T viewModel) {}

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
    widget.awake(viewModels.first);
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
