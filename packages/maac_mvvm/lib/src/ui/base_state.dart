import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/ui/ui.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// BaseViewModelState is an abstract class for managing the state of a widget
/// that needs visibility detection and dependency injection using GetIt.
/// This class leverages a unique visibility detector key for each instance,
/// enabling scoped dependency management based on visibility changes.
abstract class BaseViewModelState<T extends ViewStatefulWidget>
    extends ViewState<T> {
  final _visibilityDetectorKey = UniqueKey();

  /// Unique key used for visibility detection and scope identification.
  get visibilityDetectorKey => _visibilityDetectorKey;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      key: _visibilityDetectorKey,
      child: childBuilder,
    );
  }

  /// Callback triggered when the visibility of the widget changes.
  /// It notifies the lifecycle manager about visibility changes.
  void _onVisibilityChanged(VisibilityInfo info) {
    lifeCycleManager.onVisibilityChanged(info);
  }

  /// Abstract getter to provide the child widget to be rendered,
  /// implemented by subclasses to specify the child widget structure.
  Widget get childBuilder;
}
