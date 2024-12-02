import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
