import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'config/test_config.dart';
import 'config/test_config.mocks.dart';

void main() {
  setUp(() {
    sl.reset();
    resetViewModelSL();
    mockDi();
  });
  tearDown(() {
    resetViewModelSL();
    sl.reset();
  });
  testWidgets(
    'TestViewModelWidget registers and unregisters ViewModel in GetIt',
    (tester) async {
      const widgetTest = DependencyViewModelWidgetTest();
      await setupTester(tester: tester, child: widgetTest);
      await tester.pumpAndSettle();
      //Verify that the ViewModel is registered.
      expect(sl.isRegistered<MockExampleViewModel>(), true);
      // Dispose of the widget and verify ViewModel unregisters.
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      expect(sl.isRegistered<MockExampleViewModel>(), false);
    },
  );
  testWidgets(
    'TestViewModelsWidget registers and unregisters ViewModel in GetIt',
    (tester) async {
      const widgetTest = DependencyViewModelsWidgetTest();
      await setupTester(tester: tester, child: widgetTest);
      // Check that `awake` is called.
      await tester.pumpAndSettle();
      //Verify that the ViewModels is registered.
      expect(sl.isRegistered<MockExampleViewModel>(), true);
      expect(sl.isRegistered<MockExampleSecondViewModel>(), true);
      // Dispose of the widget and verify ViewModel unregisters.
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
      expect(sl.isRegistered<MockExampleViewModel>(), false);
      expect(sl.isRegistered<MockExampleSecondViewModel>(), false);
    },
  );
}
