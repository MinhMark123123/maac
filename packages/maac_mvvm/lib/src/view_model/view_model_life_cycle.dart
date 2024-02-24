import 'package:flutter/foundation.dart';

/// The abstract base class for a ViewModel with lifecycle callbacks in Flutter.
abstract class ViewModelLifecycle {
  /// [onInitState] is called only once when the widget has been initialized
  /// and inserted into the widget tree, before the [build] method of the widget is called.
  ///
  /// [onInitState] is equivalent to [initState] of StatefulWidget.
  @mustCallSuper
  void onInitState() {}

  /// [onDispose] is called only once when the widget is disposed from the widget tree,
  /// to clean up resources such as streams, timers, and tasks that the ViewModel is holding.
  ///
  /// [onDispose] is equivalent to [dispose] of StatefulWidget.
  @mustCallSuper
  void onDispose() {}

  /// [onResume] is called when the widget is fully displayed in the foreground.
  /// [onResume] will be called in the following cases:
  ///
  ///- after [onInitState]
  ///- after [onApplicationResumed] when the user returns to the app from the background
  ///- after returning and redisplaying after navigating from another screen using the push method.
  @mustCallSuper
  void onResume() {}

  /// [onPause] is called when the widget is no longer fully displayed in the foreground.
  /// [onPause] will be called in the following cases:
  ///
  ///- before [onApplicationPaused] when the user returns to the app from the background
  ///- when the user moves to another screen and the widget is completely removed
  /// from the widget tree, then [onDispose] will be called immediately afterwards.
  @mustCallSuper
  void onPause() {}

  /// The application is visible and responding to user input.
  @mustCallSuper
  void onApplicationResumed() {}

  /// The application is in an inactive state and is not receiving user input.
  ///
  /// On iOS, this state corresponds to an app or the Flutter host view running
  /// in the foreground inactive state. Apps transition to this state when in
  /// a phone call, responding to a TouchID request, when entering the app
  /// switcher or the control center, or when the UIViewController hosting the
  /// Flutter app is transitioning.
  ///
  /// On Android, this corresponds to an app or the Flutter host view running
  /// in the foreground inactive state.  Apps transition to this state when
  /// another activity is focused, such as a split-screen app, a phone call,
  /// a picture-in-picture app, a system dialog, or another window.
  ///
  /// Apps in this state should assume that they may be [paused] at any time.
  @mustCallSuper
  void onApplicationInactive() {}

  /// The application is not currently visible to the user, not responding to
  /// user input, and running in the background.
  ///
  /// When the application is in this state, the engine will not call the
  /// [PlatformDispatcher.onBeginFrame] and [PlatformDispatcher.onDrawFrame]
  /// callbacks.
  @mustCallSuper
  void onApplicationPaused() {}

  /// The application is still hosted on a flutter engine but is detached from
  /// any host views.
  ///
  /// When the application is in this state, the engine is running without
  /// a view. It can either be in the progress of attaching a view when engine
  /// was first initializes, or after the view being destroyed due to a Navigator
  /// pop.
  @mustCallSuper
  void onApplicationDetached() {}
  /// The application is still hosted on a flutter engine but is detached from
  /// any host views.
  ///
  /// When the application is in this state, the engine is running without
  /// a view. It can either be in the progress of attaching a view when engine
  /// was first initializes, or after the view being destroyed due to a Navigator
  /// pop.
  @mustCallSuper
  void onApplicationHidden() {}
}
