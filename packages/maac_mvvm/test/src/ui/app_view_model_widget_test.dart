import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/src/ui/ui.dart';
import 'package:mockito/mockito.dart';

import '../legacy/mocker.dart';
import '../legacy/mocker.mocks.dart';
import '../legacy/setup_config.dart';

void main() {
  late MockTestViewModel mockViewModel1;
  late MockTestViewModel mockViewModel2;
  late TestViewModelWidget testWidget;
  late TestViewModelsWidget testVMsWidget;

  setUp(() {
    mockViewModel1 = MockTestViewModel();
    mockViewModel2 = MockTestViewModel();
    testWidget = TestViewModelWidget(mockViewModel1);
    testVMsWidget = TestViewModelsWidget([mockViewModel1, mockViewModel2]);
  });
  group('ViewModelWidget Tests', () {
    testWidgets('test createViewModel and awake in correct order',
        (tester) async {
      await setupTesterWidget(tester: tester, child: testWidget);

      final BaseViewModelState state =
          tester.state(find.byType(TestViewModelWidget)) as BaseViewModelState;
      expect(state.viewModels.first == mockViewModel1, true);
    });

    testWidgets('test correct ViewModel to build method', (tester) async {
      await setupTesterWidget(tester: tester, child: testWidget);

      expect(
          find.text('ViewModel: ${mockViewModel1.hashCode}'), findsOneWidget);
    });

    testWidgets('test AwakeContext in awake method', (tester) async {
      await setupTesterWidget(tester: tester, child: testWidget);

      verify(mockViewModel1.setUpData())
          .called(1); // Validate AwakeContext interaction
    });
  });
  group('ViewModelsWidget Tests', () {
    testWidgets('Should call createViewModels and awake in correct order',
        (WidgetTester tester) async {
      await setupTesterWidget(tester: tester, child: testVMsWidget);

      final BaseViewModelState state =
          tester.state(find.byType(TestViewModelsWidget)) as BaseViewModelState;

      expect(state.viewModels[0] == mockViewModel1, true);
      expect(state.viewModels[1] == mockViewModel2, true);
    });

    testWidgets('Should pass correct ViewModels to build method',
        (WidgetTester tester) async {
      await setupTesterWidget(tester: tester, child: testVMsWidget);

      expect(
          find.text('ViewModel 1: ${mockViewModel1.hashCode}'), findsOneWidget);
      expect(
          find.text('ViewModel 2: ${mockViewModel2.hashCode}'), findsOneWidget);
    });

    testWidgets('Should use AwakeContext in awake method',
        (WidgetTester tester) async {
      await setupTesterWidget(tester: tester, child: testVMsWidget);

      verify(mockViewModel1.setUpData()).called(1);
      verify(mockViewModel2.setUpData()).called(1);
    });
  });
}
