import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../legacy/mocker.dart';
import '../legacy/mocker.mocks.dart';
import '../legacy/setup_config.dart';

void main() {
  late MockLifeCycleManager mockLifeCycleManager;
  late TestViewStatefulWidget testWidget;
  setUp(() {
    mockLifeCycleManager = MockLifeCycleManager();
    testWidget = TestViewStatefulWidget(lifeCycleManager: mockLifeCycleManager);
  });
  testWidgets('test initialize lifecycle on initState', (tester) async {
    await setupTesterWidget(tester: tester, child: testWidget);

    final TestViewState state =
        tester.state(find.byType(TestViewStatefulWidget)) as TestViewState;

    // Verify the lifecycle methods are called correctly
    expect(state.viewModels, isNotEmpty);
    expect(state.lifeCycleManager, isNotNull);
  });

  testWidgets('test activate and deactivate life methods', (tester) async {
    await setupTesterWidget(tester: tester, child: testWidget);
    final TestViewState state =
        tester.state(find.byType(TestViewStatefulWidget)) as TestViewState;
    state.activate();
    verify(state.lifeCycleManager.widgetActivate(state.uniqueKey)).called(1);
    //verify(state.lifeCycleManager.widgetActivate(state.uniqueKey)).called(1);
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
    verify(state.lifeCycleManager.widgetDeActivate(state.uniqueKey)).called(1);
  });

  testWidgets('Should handle didUpdateWidget lifecycle method',
      (WidgetTester tester) async {
    await setupTesterWidget(tester: tester, child: testWidget);
    final TestViewState state =
        tester.state(find.byType(TestViewStatefulWidget)) as TestViewState;
    final newWidget = TestViewStatefulWidget(
      lifeCycleManager: mockLifeCycleManager,
    );

    state.didUpdateWidget(newWidget);
    verify(mockLifeCycleManager.widgetDidUpdateWidget<TestViewStatefulWidget>(
      lifeOwnerKey: state.uniqueKey,
      widget: anyNamed('widget'),
      oldWidget: anyNamed('oldWidget'),
    )).called(1);
  });

  testWidgets('Should call didChangeDependencies lifecycle method',
      (WidgetTester tester) async {
    await setupTesterWidget(tester: tester, child: testWidget);

    verify(mockLifeCycleManager.widgetDidChangeDependencies(any)).called(1);
  });

  testWidgets('Should clean up on dispose', (WidgetTester tester) async {
    await setupTesterWidget(tester: tester, child: testWidget);

    await tester.pumpWidget(Container()); // Remove the widget from the tree
    verify(mockLifeCycleManager.dispose(any)).called(1);
  });
}
