import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../legacy/mocker.dart';
import '../legacy/mocker.mocks.dart';
import '../legacy/setup_config.dart';

void main() {
  late MockTestViewModel mockViewModel1;
  late StreamDataViewModel<int> mockMutableStream;
  late StreamData<int> mockStreamData;
  setUp(() {
    mockViewModel1 = MockTestViewModel();
    mockMutableStream = 0.mutableData(mockViewModel1);
    mockStreamData = mockMutableStream.streamData;
  });
  testWidgets('displays initial data correctly', (tester) async {
    await setupTesterWidget(
      tester: tester,
      child: mockStreamWidget(mockStreamData),
    );
    // Verify the initial text is displayed
    expect(find.text('Value: 0'), findsOneWidget);
  });

  testWidgets('updates when new data is emitted', (tester) async {
    // Build the StreamDataConsumer with initial data
    await setupTesterWidget(
      tester: tester,
      child: mockStreamWidget(mockStreamData),
    );

    // Emit new data (value: 5)
    mockMutableStream.postValue(5);

    // Wait for the stream update
    await tester.pumpAndSettle();

    // Verify the updated text is displayed
    expect(find.text('Value: 5'), findsOneWidget);
  });

  testWidgets('reuses cached child when appropriate', (tester) async {
    await setupTesterWidget(
      tester: tester,
      child: mockStreamWidget(mockStreamData, useCache: (value) => value == 5),
    );
    // Emit new data to trigger a rebuild
    mockMutableStream.postValue(1);
    await tester.pumpAndSettle();
    // Verify the text is still shown
    expect(find.text('Value: 1'), findsOneWidget);
    mockMutableStream.postValue(5);
    await tester.pumpAndSettle();
    expect(find.text('Value: 1'), findsOneWidget);
  });
}
