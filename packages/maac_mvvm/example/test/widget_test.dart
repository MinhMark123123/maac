// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_example/main.dart';

import 'src/legacy/setup_config.dart';

void main() {
  testWidgets('displays initial counter value', (tester) async {
    // Build the ExamplePage
    await setupTesterWidget(tester: tester, child: const ExamplePage());

    // Verify the initial text is displayed
    expect(
      find.text('You have pushed the button this many times:'),
      findsOneWidget,
    );
    expect(find.text('0'), findsOneWidget); // Initial counter value is 0
  });

  testWidgets('increments counter when FAB is pressed', (tester) async {
    // Build the ExamplePage
    await setupTesterWidget(tester: tester, child: const ExamplePage());

    // Verify initial state
    expect(find.text('0'), findsOneWidget);

    // Find the FloatingActionButton and tap it
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump(); // Trigger UI rebuild

    // Verify that the counter increments to 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // Tap the FAB again
    await tester.tap(fab);
    await tester.pump();

    // Verify that the counter increments to 2
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
      'StreamDataConsumer updates correctly when ViewModel changes state',
      (tester) async {
    // Build the ExamplePage
    await setupTesterWidget(tester: tester, child: const ExamplePage());

    // Verify initial state
    expect(find.text('0'), findsOneWidget);

    // Access the ViewModel and increment the counter directly
    final statefulWidgetFinder = find.byType(ExamplePage);
    final state = tester.state(statefulWidgetFinder) as BaseViewModelState;
    final viewModel = state.viewModels.first as ExamplePageViewModel;
    // Increment counter programmatically
    viewModel.incrementCounter();
    await tester.pumpAndSettle(); // Trigger UI rebuild

    // Verify the counter is updated in the UI
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('StreamDataConsumer updates correctly when pump button',
      (tester) async {
    // Build the ExamplePage
    await setupTesterWidget(tester: tester, child: const ExamplePage());

    // Verify initial state
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    // Increment counter programmatically
    await tester.pumpAndSettle(); // Trigger UI rebuild

    // Verify the counter is updated in the UI
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    // Increment counter programmatically
    await tester.pumpAndSettle(); // Trigger UI rebuild

    // Verify the counter is updated in the UI
    expect(find.text('2'), findsOneWidget);
  });
}
