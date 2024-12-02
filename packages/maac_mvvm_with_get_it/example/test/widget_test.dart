// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:maac_mvvm_with_get_it_example/main.dart';
import 'package:mockito/mockito.dart';

import 'src/legacy/mocker.mocks.dart';
import 'src/legacy/setup_config.dart';

GetIt sl = GetIt.instance;

void main() {
  group('normal di', () {
    setUp(() async {
      //reset
      await GetIt.I.reset();
      await resetViewModelSL();
      //register
      setupGetIt();
      registerViewModels();
    });

    testWidgets('displays initial counter value example', (tester) async {
      await setupTesterWidget(tester: tester, child: const ExamplePage());
      final statefulWidgetFinder = find.byType(ExamplePage);
      final state = tester.state(statefulWidgetFinder) as BaseViewModelState;
      final viewModel = state.viewModels.first as ExamplePageViewModel;
      //verify init
      expect(viewModel.uiState.data == 0, true);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays update fab counter value example', (tester) async {
      await setupTesterWidget(tester: tester, child: const ExamplePage());
      final statefulWidgetFinder = find.byType(ExamplePage);
      final state = tester.state(statefulWidgetFinder) as BaseViewModelState;
      final viewModel = state.viewModels.first as ExamplePageViewModel;
      //verify init
      expect(viewModel.uiState.data == 0, true);
      expect(find.text('0'), findsOneWidget);
      //increment counter
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('navigates to ExampleAPage and updates UI', (tester) async {
      await setupTesterWidget(tester: tester, child: const ExamplePage());

      // Navigate to ExampleAPage
      final buttonA = find.text("Move to A");
      await tester.tap(buttonA);
      await tester.pumpAndSettle();

      // Verify navigation and initial state
      expect(find.text("A"), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // uiStateMap adds 3

      // Increment counter
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify counter and mapped value updates
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget); // uiStateMap updates accordingly
    });

    testWidgets('navigates to ExampleBPage, fetches data, and updates UI',
        (tester) async {
      await setupTesterWidget(tester: tester, child: const ExamplePage());

      // Navigate to ExampleBPage
      final buttonB = find.text("Move to B");
      await tester.tap(buttonB);
      await tester.pumpAndSettle();

      // Verify navigation and initial state
      expect(find.text("B"), findsOneWidget);
      expect(find.text('You have pushed the button this many times:'),
          findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Initial counter value

      // Wait for fake fetch to complete
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text("Hello there!"),
          findsOneWidget); // Data fetched from repository

      // Increment counter
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify counter increment
      expect(find.text('1'), findsOneWidget);
    });
  });
  group('mock viewmodel test lifecycle', () {
    late MockExamplePageViewModel mockExamplePageViewModel;
    late MockExampleAPageViewModel mockExampleAPageViewModel;
    late MockExampleBPageViewModel mockExampleBPageViewModel;
    setUp(() async {
      await GetIt.I.reset();
      await resetViewModelSL();
      //register
      setupGetIt();
      mockExamplePageViewModel = MockExamplePageViewModel();
      mockExampleAPageViewModel = MockExampleAPageViewModel();
      mockExampleBPageViewModel = MockExampleBPageViewModel();
      when(mockExamplePageViewModel.uiState).thenReturn(
        StreamDataViewModel(
          defaultValue: 0,
          viewModel: mockExamplePageViewModel,
        ).streamData,
      );
      when(mockExampleAPageViewModel.uiState).thenReturn(
        StreamDataViewModel(
          defaultValue: 0,
          viewModel: mockExampleAPageViewModel,
        ).streamData,
      );
      when(mockExampleAPageViewModel.uiStateMap).thenReturn(
        StreamDataViewModel(
          defaultValue: "",
          viewModel: mockExampleAPageViewModel,
        ).streamData,
      );
      when(mockExampleBPageViewModel.uiState).thenReturn(
        StreamDataViewModel(
          defaultValue: 0,
          viewModel: mockExampleBPageViewModel,
        ).streamData,
      );
      when(mockExampleBPageViewModel.dataApi).thenReturn(
        StreamDataViewModel(
          defaultValue: "",
          viewModel: mockExampleBPageViewModel,
        ).streamData,
      );
      registerMockViewModels(
        mockExamplePageViewModel: mockExamplePageViewModel,
        mockExampleAPageViewModel: mockExampleAPageViewModel,
        mockExampleBPageViewModel: mockExampleBPageViewModel,
      );
    });
    testWidgets('navigates to ExampleAPage ', (tester) async {
      // Setup the testing environment by wrapping the widget under test (ExamplePage) in the necessary context
      await setupTesterWidget(tester: tester, child: const ExamplePage());

      // Retrieve the ViewModel for ExamplePage
      final examplePageViewModel = sl.get<ExamplePageViewModel>();

      // Verify that the lifecycle methods of ExamplePageViewModel are called as expected during initialization
      // onInitState is called once
      verify(examplePageViewModel.onInitState()).called(1);
      // onResume is called once
      verify(examplePageViewModel.onResume()).called(1);
      /*
        Simulate navigation to ExampleAPage
        This section triggers the button tap and performs navigation.
      */
      final buttonA = find.text("Move to A");
      await tester.tap(buttonA);
      // Wait for animations and navigation to settle
      await tester.pumpAndSettle();

      // Retrieve the ViewModel for ExampleAPage
      final exampleAPageViewModel = sl.get<ExampleAPageViewModel>();

      // Verify the lifecycle methods of the ViewModels during the navigation process
      //=======
      // Verify that ExamplePageViewModel is paused
      verify(examplePageViewModel.onPause()).called(1);
      // Ensure that ExamplePageViewModel is not disposed
      verifyNever(examplePageViewModel.onDispose());
      // Verify ExampleAPageViewModel is initialized
      verify(exampleAPageViewModel.onInitState()).called(1);
      // Verify ExampleAPageViewModel is resumed
      verify(exampleAPageViewModel.onResume()).called(1);
    });
    testWidgets('navigates to ExampleAPage and back', (tester) async {
      // Setup the testing environment by wrapping the widget under test (ExamplePage) in the necessary context
      await setupTesterWidget(tester: tester, child: const ExamplePage());
      // Retrieve the ViewModel for ExamplePage
      final examplePageViewModel = sl.get<ExamplePageViewModel>();
      /*
        Simulate navigation to ExampleAPage
        This section triggers the button tap and performs navigation.
      */
      final buttonA = find.text("Move to A");
      await tester.tap(buttonA);
      // Wait for animations and navigation to settle
      await tester.pumpAndSettle();
      final statefulWidgetFinder = find.byType(ExampleAPage);
      final state = tester.state(statefulWidgetFinder) as BaseViewModelState;
      Navigator.of(state.context).pop();
      // Wait for animations and navigation to settle
      await tester.pumpAndSettle();
      // Verify the lifecycle methods of the ViewModels during the navigation process
      //=======
      // Verify ExampleAPageViewModel is initialized
      verify(mockExampleAPageViewModel.onInitState()).called(1);
      // Verify ExampleAPageViewModel is resumed
      verify(mockExampleAPageViewModel.onResume()).called(1);
      // Verify ExampleAPageViewModel is onPause
      verify(mockExampleAPageViewModel.onPause()).called(1);
      // Verify ExampleAPageViewModel is onDispose
      verify(mockExampleAPageViewModel.onDispose()).called(1);
      // Verify that the lifecycle methods of ExamplePageViewModel are called as expected during initialization
      // onInitState is called once
      verify(examplePageViewModel.onInitState()).called(1);
      // onResume is called true
      verify(examplePageViewModel.onResume()).called(2);
      verify(examplePageViewModel.onPause()).called(1);
      // Ensure that ExamplePageViewModel is not disposed
      verifyNever(examplePageViewModel.onDispose());
    });
  });
}
