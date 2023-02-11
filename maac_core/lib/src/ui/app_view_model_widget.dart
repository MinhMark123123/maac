import 'package:flutter/widgets.dart';
import 'package:maac_core/src/ui/app_life_state.dart';
import 'package:maac_core/src/view_model/view_model.dart';

abstract class ViewModelWidget<T extends ViewModel> extends ViewStatefulWidget {
  const ViewModelWidget({Key? key}) : super(key: key);

  Widget build(BuildContext context, T viewModel);

  T createViewModel();

  void aWake(T viewModel) {}

  @override
  // ignore:
  ViewState createState() => _BindViewModelWidgetState();
}

class _BindViewModelWidgetState extends ViewState<ViewModelWidget> {

  @override
  Widget build(BuildContext context) {
    return widget.build(context, viewModels.first);
  }

  @override
  List<ViewModel> bindViewModels() => [widget.createViewModel()];

  @override
  void aWake() {
    super.aWake();
    widget.aWake(viewModels.first);
  }
}