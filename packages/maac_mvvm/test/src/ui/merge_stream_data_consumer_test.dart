import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../legacy/mocker.mocks.dart';
import '../legacy/setup_config.dart';

void main() {
  late MockTestViewModel mockViewModel;
  late StreamDataViewModel<int> countStream;
  late StreamDataViewModel<String> labelStream;

  setUp(() {
    mockViewModel = MockTestViewModel();
    countStream = 0.mutableData(mockViewModel);
    labelStream = 'idle'.mutableData(mockViewModel);
  });

  testWidgets('StreamDataConsumer2 displays initial data from both sources', (tester) async {
    await setupTesterWidget(
      tester: tester,
      child: StreamDataConsumer2<int, String>(
        streamData1: countStream.streamData,
        streamData2: labelStream.streamData,
        builder: (context, count, label) => Text('$label: $count', textDirection: TextDirection.ltr),
      ),
    );
    expect(find.text('idle: 0'), findsOneWidget);
  });

  testWidgets('StreamDataConsumer2 rebuilds when either source emits', (tester) async {
    await setupTesterWidget(
      tester: tester,
      child: StreamDataConsumer2<int, String>(
        streamData1: countStream.streamData,
        streamData2: labelStream.streamData,
        builder: (context, count, label) => Text('$label: $count', textDirection: TextDirection.ltr),
      ),
    );

    countStream.postValue(5);
    await tester.pumpAndSettle();
    expect(find.text('idle: 5'), findsOneWidget);

    labelStream.postValue('running');
    await tester.pumpAndSettle();
    expect(find.text('running: 5'), findsOneWidget);
  });

  testWidgets('StreamDataConsumer3 combines three sources', (tester) async {
    final flagStream = false.mutableData(mockViewModel);
    await setupTesterWidget(
      tester: tester,
      child: StreamDataConsumer3<int, String, bool>(
        streamData1: countStream.streamData,
        streamData2: labelStream.streamData,
        streamData3: flagStream.streamData,
        builder: (context, count, label, flag) => Text('$label: $count ($flag)', textDirection: TextDirection.ltr),
      ),
    );
    expect(find.text('idle: 0 (false)'), findsOneWidget);

    flagStream.postValue(true);
    await tester.pumpAndSettle();
    expect(find.text('idle: 0 (true)'), findsOneWidget);
  });

  testWidgets('MergeStreamDataConsumer rebuilds on any source without a combined payload', (tester) async {
    var buildCount = 0;
    await setupTesterWidget(
      tester: tester,
      child: MergeStreamDataConsumer(
        streams: [countStream.streamData, labelStream.streamData],
        builder: (context) {
          buildCount++;
          return Text('${labelStream.data}: ${countStream.data}', textDirection: TextDirection.ltr);
        },
      ),
    );
    final initialBuildCount = buildCount;
    expect(find.text('idle: 0'), findsOneWidget);

    countStream.postValue(1);
    await tester.pumpAndSettle();
    expect(find.text('idle: 1'), findsOneWidget);
    expect(buildCount, greaterThan(initialBuildCount));
  });
}
