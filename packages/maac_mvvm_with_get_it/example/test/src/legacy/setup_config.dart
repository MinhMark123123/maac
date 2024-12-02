import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:maac_mvvm_with_get_it_example/main.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'mocker.mocks.dart';

Future<void> setupTester({
  required WidgetTester tester,
}) async {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  //wait for VisibilityDetectorWidget complete
  await tester.binding.delayed(
    VisibilityDetectorController.instance.updateInterval,
  );
  await tester.pumpAndSettle();
}

Future<void> setupTesterWidget({
  required WidgetTester tester,
  required Widget child,
}) async {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(MaterialApp(home: child));
  //wait for VisibilityDetectorWidget complete
  await tester.binding.delayed(
    VisibilityDetectorController.instance.updateInterval,
  );
  await tester.pumpAndSettle();
}

void registerMockViewModels({
  required MockExamplePageViewModel mockExamplePageViewModel,
  required MockExampleAPageViewModel mockExampleAPageViewModel,
  required MockExampleBPageViewModel mockExampleBPageViewModel,
}) {
  registerViewModel<ExamplePageViewModel>(() => mockExamplePageViewModel);
  registerViewModel<ExampleAPageViewModel>(() => mockExampleAPageViewModel);
  registerViewModel<ExampleBPageViewModel>(() => mockExampleBPageViewModel);
}
