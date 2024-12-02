import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/view_model/life_cycle_manager.dart';

class WrapperContext {
  final BuildContext context;
  final LifeCycleManager lifeCycleManager;

  WrapperContext({
    required this.context,
    required this.lifeCycleManager,
  });
}
