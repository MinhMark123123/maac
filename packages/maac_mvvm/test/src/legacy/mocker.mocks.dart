// Mocks generated by Mockito 5.4.4 from annotations
// in maac_mvvm/test/src/legacy/mocker.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i3;

import 'package:flutter/services.dart' as _i8;
import 'package:flutter/widgets.dart' as _i2;
import 'package:maac_mvvm/maac_mvvm.dart' as _i9;
import 'package:maac_mvvm/src/view_model/life_cycle_component.dart' as _i6;
import 'package:maac_mvvm/src/view_model/life_cycle_manager.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;
import 'package:visibility_detector/visibility_detector.dart' as _i7;

import 'mocker.dart' as _i11;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeKey_0 extends _i1.SmartFake implements _i2.Key {
  _FakeKey_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSize_1 extends _i1.SmartFake implements _i3.Size {
  _FakeSize_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRect_2 extends _i1.SmartFake implements _i3.Rect {
  _FakeRect_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBuildContext_3 extends _i1.SmartFake implements _i2.BuildContext {
  _FakeBuildContext_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLifeCycleManager_4 extends _i1.SmartFake
    implements _i4.LifeCycleManager {
  _FakeLifeCycleManager_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_5<T> extends _i1.SmartFake implements _i5.Future<T> {
  _FakeFuture_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [LifeCycleManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockLifeCycleManager extends _i1.Mock implements _i4.LifeCycleManager {
  @override
  List<_i6.LifecycleComponent> get lifecycles => (super.noSuchMethod(
        Invocation.getter(#lifecycles),
        returnValue: <_i6.LifecycleComponent>[],
        returnValueForMissingStub: <_i6.LifecycleComponent>[],
      ) as List<_i6.LifecycleComponent>);

  @override
  void registerWidgetBindLifecycle(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #registerWidgetBindLifecycle,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isValidLifeCycleHolder(String? lifeOwnerKey) => (super.noSuchMethod(
        Invocation.method(
          #isValidLifeCycleHolder,
          [lifeOwnerKey],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  void initState(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #initState,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onVisibilityChanged(_i7.VisibilityInfo? info) => super.noSuchMethod(
        Invocation.method(
          #onVisibilityChanged,
          [info],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeAppLifecycleState(_i3.AppLifecycleState? state) =>
      super.noSuchMethod(
        Invocation.method(
          #didChangeAppLifecycleState,
          [state],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onActive(dynamic Function()? actionOnActive) => super.noSuchMethod(
        Invocation.method(
          #onActive,
          [actionOnActive],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDeActive(dynamic Function()? actionOnDeActive) => super.noSuchMethod(
        Invocation.method(
          #onDeActive,
          [actionOnDeActive],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDidChangeDependencies(
          dynamic Function()? actionOnDidChangeDependencies) =>
      super.noSuchMethod(
        Invocation.method(
          #onDidChangeDependencies,
          [actionOnDidChangeDependencies],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDidUpdate(
          dynamic Function<T extends _i2.Widget>(T)? actionOnDidUpdate) =>
      super.noSuchMethod(
        Invocation.method(
          #onDidUpdate,
          [actionOnDidUpdate],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDispose(dynamic Function()? actionOnDispose) => super.noSuchMethod(
        Invocation.method(
          #onDispose,
          [actionOnDispose],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void widgetActivate(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #widgetActivate,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void widgetDeActivate(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #widgetDeActivate,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void widgetDidChangeDependencies(String? lifeOwnerKey) => super.noSuchMethod(
        Invocation.method(
          #widgetDidChangeDependencies,
          [lifeOwnerKey],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void widgetDidUpdateWidget<T extends _i2.Widget>({
    required String? lifeOwnerKey,
    required _i2.Widget? widget,
    required T? oldWidget,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #widgetDidUpdateWidget,
          [],
          {
            #lifeOwnerKey: lifeOwnerKey,
            #widget: widget,
            #oldWidget: oldWidget,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<bool> didPopRoute() => (super.noSuchMethod(
        Invocation.method(
          #didPopRoute,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  bool handleStartBackGesture(_i8.PredictiveBackEvent? backEvent) =>
      (super.noSuchMethod(
        Invocation.method(
          #handleStartBackGesture,
          [backEvent],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  void handleUpdateBackGestureProgress(_i8.PredictiveBackEvent? backEvent) =>
      super.noSuchMethod(
        Invocation.method(
          #handleUpdateBackGestureProgress,
          [backEvent],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void handleCommitBackGesture() => super.noSuchMethod(
        Invocation.method(
          #handleCommitBackGesture,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void handleCancelBackGesture() => super.noSuchMethod(
        Invocation.method(
          #handleCancelBackGesture,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<bool> didPushRoute(String? route) => (super.noSuchMethod(
        Invocation.method(
          #didPushRoute,
          [route],
        ),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<bool> didPushRouteInformation(
          _i2.RouteInformation? routeInformation) =>
      (super.noSuchMethod(
        Invocation.method(
          #didPushRouteInformation,
          [routeInformation],
        ),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  void didChangeMetrics() => super.noSuchMethod(
        Invocation.method(
          #didChangeMetrics,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeTextScaleFactor() => super.noSuchMethod(
        Invocation.method(
          #didChangeTextScaleFactor,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangePlatformBrightness() => super.noSuchMethod(
        Invocation.method(
          #didChangePlatformBrightness,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeLocales(List<_i3.Locale>? locales) => super.noSuchMethod(
        Invocation.method(
          #didChangeLocales,
          [locales],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeViewFocus(_i3.ViewFocusEvent? event) => super.noSuchMethod(
        Invocation.method(
          #didChangeViewFocus,
          [event],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i3.AppExitResponse> didRequestAppExit() => (super.noSuchMethod(
        Invocation.method(
          #didRequestAppExit,
          [],
        ),
        returnValue:
            _i5.Future<_i3.AppExitResponse>.value(_i3.AppExitResponse.exit),
        returnValueForMissingStub:
            _i5.Future<_i3.AppExitResponse>.value(_i3.AppExitResponse.exit),
      ) as _i5.Future<_i3.AppExitResponse>);

  @override
  void didHaveMemoryPressure() => super.noSuchMethod(
        Invocation.method(
          #didHaveMemoryPressure,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeAccessibilityFeatures() => super.noSuchMethod(
        Invocation.method(
          #didChangeAccessibilityFeatures,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [LifecycleComponent].
///
/// See the documentation for Mockito's code generation for more information.
class MockLifecycleComponent extends _i1.Mock
    implements _i6.LifecycleComponent {
  @override
  void onInitState() => super.noSuchMethod(
        Invocation.method(
          #onInitState,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDispose() => super.noSuchMethod(
        Invocation.method(
          #onDispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onResume() => super.noSuchMethod(
        Invocation.method(
          #onResume,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onPause() => super.noSuchMethod(
        Invocation.method(
          #onPause,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationResumed() => super.noSuchMethod(
        Invocation.method(
          #onApplicationResumed,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationInactive() => super.noSuchMethod(
        Invocation.method(
          #onApplicationInactive,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationPaused() => super.noSuchMethod(
        Invocation.method(
          #onApplicationPaused,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationDetached() => super.noSuchMethod(
        Invocation.method(
          #onApplicationDetached,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationHidden() => super.noSuchMethod(
        Invocation.method(
          #onApplicationHidden,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [VisibilityInfo].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockVisibilityInfo extends _i1.Mock implements _i7.VisibilityInfo {
  @override
  _i2.Key get key => (super.noSuchMethod(
        Invocation.getter(#key),
        returnValue: _FakeKey_0(
          this,
          Invocation.getter(#key),
        ),
        returnValueForMissingStub: _FakeKey_0(
          this,
          Invocation.getter(#key),
        ),
      ) as _i2.Key);

  @override
  _i3.Size get size => (super.noSuchMethod(
        Invocation.getter(#size),
        returnValue: _FakeSize_1(
          this,
          Invocation.getter(#size),
        ),
        returnValueForMissingStub: _FakeSize_1(
          this,
          Invocation.getter(#size),
        ),
      ) as _i3.Size);

  @override
  _i3.Rect get visibleBounds => (super.noSuchMethod(
        Invocation.getter(#visibleBounds),
        returnValue: _FakeRect_2(
          this,
          Invocation.getter(#visibleBounds),
        ),
        returnValueForMissingStub: _FakeRect_2(
          this,
          Invocation.getter(#visibleBounds),
        ),
      ) as _i3.Rect);

  @override
  double get visibleFraction => (super.noSuchMethod(
        Invocation.getter(#visibleFraction),
        returnValue: 0.0,
        returnValueForMissingStub: 0.0,
      ) as double);

  @override
  bool matchesVisibility(_i7.VisibilityInfo? info) => (super.noSuchMethod(
        Invocation.method(
          #matchesVisibility,
          [info],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
}

/// A class which mocks [AwakeContext].
///
/// See the documentation for Mockito's code generation for more information.
class MockAwakeContext extends _i1.Mock implements _i9.WrapperContext {
  @override
  _i2.BuildContext get context => (super.noSuchMethod(
        Invocation.getter(#context),
        returnValue: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
        returnValueForMissingStub: _FakeBuildContext_3(
          this,
          Invocation.getter(#context),
        ),
      ) as _i2.BuildContext);

  @override
  _i4.LifeCycleManager get lifeCycleManager => (super.noSuchMethod(
        Invocation.getter(#lifeCycleManager),
        returnValue: _FakeLifeCycleManager_4(
          this,
          Invocation.getter(#lifeCycleManager),
        ),
        returnValueForMissingStub: _FakeLifeCycleManager_4(
          this,
          Invocation.getter(#lifeCycleManager),
        ),
      ) as _i4.LifeCycleManager);
}

/// A class which mocks [ViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockViewModel extends _i1.Mock implements _i9.ViewModel {
  @override
  bool get isBoundLifeCycle => (super.noSuchMethod(
        Invocation.getter(#isBoundLifeCycle),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  void onInitState() => super.noSuchMethod(
        Invocation.method(
          #onInitState,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDispose() => super.noSuchMethod(
        Invocation.method(
          #onDispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<G> viewModelScope<G>(
    _i5.Future<G> Function()? future, {
    _i2.Key? key,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #viewModelScope,
          [future],
          {#key: key},
        ),
        returnValue: _i10.ifNotNull(
              _i10.dummyValueOrNull<G>(
                this,
                Invocation.method(
                  #viewModelScope,
                  [future],
                  {#key: key},
                ),
              ),
              (G v) => _i5.Future<G>.value(v),
            ) ??
            _FakeFuture_5<G>(
              this,
              Invocation.method(
                #viewModelScope,
                [future],
                {#key: key},
              ),
            ),
        returnValueForMissingStub: _i10.ifNotNull(
              _i10.dummyValueOrNull<G>(
                this,
                Invocation.method(
                  #viewModelScope,
                  [future],
                  {#key: key},
                ),
              ),
              (G v) => _i5.Future<G>.value(v),
            ) ??
            _FakeFuture_5<G>(
              this,
              Invocation.method(
                #viewModelScope,
                [future],
                {#key: key},
              ),
            ),
      ) as _i5.Future<G>);

  @override
  void cancelByKey(_i2.Key? key) => super.noSuchMethod(
        Invocation.method(
          #cancelByKey,
          [key],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addComponents(_i6.LifecycleComponent? lifecycleComponent) =>
      super.noSuchMethod(
        Invocation.method(
          #addComponents,
          [lifecycleComponent],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void markViewModelHasBondLifeCycle() => super.noSuchMethod(
        Invocation.method(
          #markViewModelHasBondLifeCycle,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onResume() => super.noSuchMethod(
        Invocation.method(
          #onResume,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onPause() => super.noSuchMethod(
        Invocation.method(
          #onPause,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationResumed() => super.noSuchMethod(
        Invocation.method(
          #onApplicationResumed,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationInactive() => super.noSuchMethod(
        Invocation.method(
          #onApplicationInactive,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationPaused() => super.noSuchMethod(
        Invocation.method(
          #onApplicationPaused,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationDetached() => super.noSuchMethod(
        Invocation.method(
          #onApplicationDetached,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationHidden() => super.noSuchMethod(
        Invocation.method(
          #onApplicationHidden,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestViewModel extends _i1.Mock implements _i11.TestViewModel {
  @override
  bool get isBoundLifeCycle => (super.noSuchMethod(
        Invocation.getter(#isBoundLifeCycle),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  void setup() => super.noSuchMethod(
        Invocation.method(
          #setup,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onInitState() => super.noSuchMethod(
        Invocation.method(
          #onInitState,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onDispose() => super.noSuchMethod(
        Invocation.method(
          #onDispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<G> viewModelScope<G>(
    _i5.Future<G> Function()? future, {
    _i2.Key? key,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #viewModelScope,
          [future],
          {#key: key},
        ),
        returnValue: _i10.ifNotNull(
              _i10.dummyValueOrNull<G>(
                this,
                Invocation.method(
                  #viewModelScope,
                  [future],
                  {#key: key},
                ),
              ),
              (G v) => _i5.Future<G>.value(v),
            ) ??
            _FakeFuture_5<G>(
              this,
              Invocation.method(
                #viewModelScope,
                [future],
                {#key: key},
              ),
            ),
        returnValueForMissingStub: _i10.ifNotNull(
              _i10.dummyValueOrNull<G>(
                this,
                Invocation.method(
                  #viewModelScope,
                  [future],
                  {#key: key},
                ),
              ),
              (G v) => _i5.Future<G>.value(v),
            ) ??
            _FakeFuture_5<G>(
              this,
              Invocation.method(
                #viewModelScope,
                [future],
                {#key: key},
              ),
            ),
      ) as _i5.Future<G>);

  @override
  void cancelByKey(_i2.Key? key) => super.noSuchMethod(
        Invocation.method(
          #cancelByKey,
          [key],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addComponents(_i6.LifecycleComponent? lifecycleComponent) =>
      super.noSuchMethod(
        Invocation.method(
          #addComponents,
          [lifecycleComponent],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void markViewModelHasBondLifeCycle() => super.noSuchMethod(
        Invocation.method(
          #markViewModelHasBondLifeCycle,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onResume() => super.noSuchMethod(
        Invocation.method(
          #onResume,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onPause() => super.noSuchMethod(
        Invocation.method(
          #onPause,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationResumed() => super.noSuchMethod(
        Invocation.method(
          #onApplicationResumed,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationInactive() => super.noSuchMethod(
        Invocation.method(
          #onApplicationInactive,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationPaused() => super.noSuchMethod(
        Invocation.method(
          #onApplicationPaused,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationDetached() => super.noSuchMethod(
        Invocation.method(
          #onApplicationDetached,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onApplicationHidden() => super.noSuchMethod(
        Invocation.method(
          #onApplicationHidden,
          [],
        ),
        returnValueForMissingStub: null,
      );
}