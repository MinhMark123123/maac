import 'package:flutter/widgets.dart';
import 'package:maac_core/src/navigate/delegate_navigation.dart';

abstract class UIState {
  final BuildContext _buildContext;
  final DelegateNavigation _navigation;

  DelegateNavigation get navigation => _navigation;

  BuildContext get buildContext => _buildContext;

  UIState({
    required BuildContext buildContext,
    required DelegateNavigation navigation,
  })  : _buildContext = buildContext,
        _navigation = navigation;
}
