import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../../legacy/mocker.dart';

void main() {
  late TestViewModel viewModel;
  late StreamDataViewModel<int> streamData;

  setUp(() {
    viewModel = TestViewModel();
    streamData = 0.mutableData(viewModel);
  });
  tearDown(() {
    viewModel.onDispose();
  });
  test('Initial value is set correctly', () {
    // Assert
    expect(streamData.data, 0);
  });

  test('postValue updates data and notifies stream listeners', () async {
    // Arrange
    final values = <int>[];
    final subscription = streamData.asStream().listen((data) {
      values.add(data);
    });

    // Act
    streamData.postValue(1);
    streamData.postValue(2);
    streamData.postValue(2); // Duplicate, should not add to stream
    streamData.postValue(3);

    await Future.delayed(Duration.zero); // Wait for async notifications

    // Assert
    expect(values, equals([1, 2, 3]));

    // Clean up
    await subscription.cancel();
  });

  test('setValue updates data silently', () {
    // Act
    streamData.setValue(5);

    // Assert
    expect(streamData.data, equals(5));
  });

  test('StreamDataViewModel disposes stream and subscriptions on dispose',
      () async {
    // Arrange
    bool isStreamClosed = false;

    streamData.asStream().listen(
      (_) {},
      onDone: () {
        isStreamClosed = true;
      },
    );

    // Act
    viewModel.onDispose();
    await Future.delayed(const Duration(milliseconds: 10));
    // Assert
    expect(isStreamClosed, isTrue);
  });

  test('StreamDataViewModel supports mapping transformations', () async {
    // Arrange
    final mappedStream = streamData.map<String>(
      mapper: (data) => 'Value: $data',
    );

    final mappedValues = <String>[];
    final subscription = mappedStream.asStream().listen((data) {
      mappedValues.add(data);
    });

    // Act
    streamData.postValue(1);
    streamData.postValue(2);
    streamData.postValue(3);

    await Future.delayed(Duration.zero); // Wait for async notifications

    // Assert
    expect(mappedValues, equals(['Value: 1', 'Value: 2', 'Value: 3']));

    // Clean up
    await subscription.cancel();
  });

  test('MediatorStreamData can add sources and notify listeners', () async {
    // Arrange
    final mediatorStreamData = MediatorStreamData<int>(
      defaultValue: 0,
      viewModel: viewModel,
    );

    final sourceController = StreamController<int>();
    final values = <int>[];

    mediatorStreamData.addSource<int>(
      sourceController.stream,
      (data) {
        mediatorStreamData.postValue(data);
      },
    );

    mediatorStreamData.asStream().listen((data) {
      values.add(data);
    });

    // Act
    sourceController.add(10);
    sourceController.add(20);
    sourceController.add(30);

    await Future.delayed(Duration.zero); // Wait for async notifications

    // Assert
    expect(values, equals([10, 20, 30]));

    // Clean up
    await sourceController.close();
  });

  test('MediatorStreamData disposes all subscriptions on dispose', () async {
    // Arrange
    final mediatorStreamData = MediatorStreamData<int>(
      defaultValue: 0,
      viewModel: viewModel,
    );

    final sourceController = StreamController<int>();
    final stream = sourceController.stream;
    mediatorStreamData.addSource<int>(
      stream,
      (data) {
        mediatorStreamData.postValue(data);
      },
    );

    // Act
    viewModel.onDispose();
    await Future.delayed(const Duration(milliseconds: 10));
    // Assert
    sourceController.add(10);
    await Future.delayed(const Duration(milliseconds: 10));
    expect(mediatorStreamData.data, 0);
    // Clean up
    await sourceController.close();
  });
}
