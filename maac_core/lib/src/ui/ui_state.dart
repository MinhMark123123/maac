import 'package:flutter/widgets.dart';
import 'package:maac_core/src/navigate/delegate_navigation.dart';

abstract class UIState {
  final DelegateNavigation _navigation;

  DelegateNavigation get navigation => _navigation;

  UIState({
    required DelegateNavigation navigation,
  }) : _navigation = navigation;
}
