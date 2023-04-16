// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:visibility_detector/visibility_detector.dart';

@GenerateNiceMocks(
    [MockSpec<ExamplePageViewModel>(), MockSpec<StreamDataViewModel<int>>()])
import 'widget_test.mocks.dart';

GetIt sl = GetIt.instance;

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  final mockStream = MockStreamDataViewModel();
  final mockViewModel = MockExamplePageViewModel();

  setUpAll(() {
    GetIt.I.reset();
    when(mockViewModel.uiState).thenAnswer((_) => mockStream);
    when(mockStream.data).thenReturn(1);
  });
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    // Build our app and trigger a frame.
    const exampleApp = ExamplePage();
    exampleApp.setupMockViewModel(mockViewModel);
    //pub widget
    await tester.pumpWidget(const MaterialApp(home: exampleApp));
    //wait for VisibilityDetectorWidget complete
    await tester.binding
        .delayed(VisibilityDetectorController.instance.updateInterval);
    //verify mocked ViewModel value
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
