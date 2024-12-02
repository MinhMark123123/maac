import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:mockito/mockito.dart';

import '../legacy/mocker.mocks.dart';
import '../legacy/setup_config.dart';

void main() {
  late LifeCycleManager lifeCycleManager;
  late MockLifecycleComponent mockLifecycleComponent;
  late MockLifecycleComponent mockLifecycleComponent2;
  late String uniqueKey;
  final MockVisibilityInfo mockVisibilityInfo = MockVisibilityInfo();
  final MockVisibilityInfo mockVisibilityInfo2 = MockVisibilityInfo();

  setUp(() {
    uniqueKey = UniqueKey().toString();
    mockLifecycleComponent = MockLifecycleComponent();
    mockLifecycleComponent2 = MockLifecycleComponent();
    lifeCycleManager = LifeCycleManager([
      mockLifecycleComponent,
      mockLifecycleComponent2,
    ]);
  });

  testWidgets('initState should call onInitState and onResume', (tester) async {
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.initState(uniqueKey);
    await tester.pumpAndSettle();
    verify(mockLifecycleComponent.onInitState()).called(1);
    verify(mockLifecycleComponent2.onInitState()).called(1);
  });

  testWidgets('dispose should call onDispose', (tester) async {
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.initState(uniqueKey);
    await tester.pumpAndSettle();
    lifeCycleManager.dispose(uniqueKey);
    verify(mockLifecycleComponent.onDispose()).called(1);
    verify(mockLifecycleComponent2.onDispose()).called(1);
  });

  testWidgets('onVisibilityChanged should call onResume when visible',
      (tester) async {
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.initState(uniqueKey);
    await tester.pumpAndSettle();

    lifeCycleManager.onVisibilityChanged(mockVisibilityInfo);

    verify(mockLifecycleComponent.onResume()).called(1);
    verify(mockLifecycleComponent2.onResume()).called(1);
  });

  testWidgets('onVisibilityChanged should call onPause when not visible',
      (tester) async {
    when(mockVisibilityInfo.visibleFraction).thenReturn(0.0);
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.initState(uniqueKey);
    await tester.pumpAndSettle();
    lifeCycleManager.onVisibilityChanged(mockVisibilityInfo);

    verify(mockLifecycleComponent.onPause()).called(1);
    verify(mockLifecycleComponent2.onPause()).called(1);
  });
  testWidgets('onVisibilityChanged should call onResume after visible again ',
      (tester) async {
    when(mockVisibilityInfo.visibleFraction).thenReturn(0.0);
    when(mockVisibilityInfo2.visibleFraction).thenReturn(1.0);
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.initState(uniqueKey);
    lifeCycleManager.onVisibilityChanged(mockVisibilityInfo2);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    lifeCycleManager.onVisibilityChanged(mockVisibilityInfo);

    verify(mockLifecycleComponent.onPause()).called(1);
    verify(mockLifecycleComponent2.onPause()).called(1);
    //
    lifeCycleManager.onVisibilityChanged(mockVisibilityInfo2);
    verify(mockLifecycleComponent.onResume()).called(2);
    verify(mockLifecycleComponent2.onResume()).called(2);
  });

  testWidgets(
      'didChangeAppLifecycleState should call appropriate lifecycle methods',
      (tester) async {
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    await tester.pumpAndSettle();
    lifeCycleManager.didChangeAppLifecycleState(AppLifecycleState.resumed);

    verify(mockLifecycleComponent.onApplicationResumed()).called(1);
    verify(mockLifecycleComponent.onResume()).called(1);

    lifeCycleManager.didChangeAppLifecycleState(AppLifecycleState.paused);

    verify(mockLifecycleComponent.onPause()).called(1);
    verify(mockLifecycleComponent.onApplicationPaused()).called(1);

    lifeCycleManager.didChangeAppLifecycleState(AppLifecycleState.inactive);

    verify(mockLifecycleComponent.onApplicationInactive()).called(1);
    lifeCycleManager.didChangeAppLifecycleState(AppLifecycleState.hidden);

    verify(mockLifecycleComponent.onPause()).called(1);
    verify(mockLifecycleComponent.onApplicationHidden()).called(1);

    lifeCycleManager.didChangeAppLifecycleState(AppLifecycleState.detached);

    verify(mockLifecycleComponent.onApplicationDetached()).called(1);
  });

  testWidgets('onActive should execute subscribed actions', (tester) async {
    bool onActiveCalled = false;
    when(mockVisibilityInfo.visibleFraction).thenReturn(0.0);
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    await tester.pumpAndSettle();
    lifeCycleManager.onActive(() {
      onActiveCalled = true;
    });

    lifeCycleManager.widgetActivate(uniqueKey);

    expect(onActiveCalled, isTrue);
  });
  testWidgets('onDeActive should execute subscribed actions', (tester) async {
    bool onDeActiveCalled = false;
    when(mockVisibilityInfo.visibleFraction).thenReturn(0.0);
    await setupTester(tester: tester);
    lifeCycleManager.registerWidgetBindLifecycle(uniqueKey);
    lifeCycleManager.onDeActive(() {
      onDeActiveCalled = true;
    });

    lifeCycleManager.widgetDeActivate(uniqueKey);

    expect(onDeActiveCalled, isTrue);
  });
}
