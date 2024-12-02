import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../legacy/mocker.dart';
import '../legacy/mocker.mocks.dart';

void main() {
  late TestViewModel viewModel;
  late MockLifecycleComponent mockComponent;

  setUp(() {
    viewModel = TestViewModel();
    mockComponent = MockLifecycleComponent();
    viewModel.addComponents(mockComponent);
  });

  tearDown(() {
    viewModel.onDispose();
  });
  test('ViewModel initializes lifecycle components on initState', () {
    // Act
    viewModel.onInitState();

    // Assert
    expect(viewModel.isBoundLifeCycle, isTrue);
    verify(mockComponent.onInitState()).called(1);
  });

  test('ViewModel disposes lifecycle components on dispose', () {
    // Act
    viewModel.onDispose();

    // Assert
    verify(mockComponent.onDispose()).called(1);
  });

  test('ViewModel cancels all operations on dispose', () async {
    // Arrange
    final key1 = UniqueKey();
    final key2 = UniqueKey();
    int int1 = -1;
    int int2 = -1;
    viewModel.viewModelScope(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 42;
    }, key: key1).then((value) => int1 = value);

    viewModel.viewModelScope(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 24;
    }, key: key2).then((value) => int2 = value);
    // Act
    viewModel.onDispose();
    //
    await Future.delayed(const Duration(seconds: 1));

    // Assert
    expect(int1, -1);
    expect(int2, -1);
  });

  test('ViewModel cancels specific operation by key', () async {
    // Arrange
    final key1 = UniqueKey();
    int int1 = -1;
    viewModel.viewModelScope(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 42;
    }, key: key1).then((value) => int1 = value);

    // Act
    viewModel.cancelByKey(key1);

    // Assert
    expect(int1, -1);
  });
  test('ViewModel cancels auto', () async {
    // Arrange
    int int1 = -1;
    viewModel.viewModelScope(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return 42;
    }).then((value) => int1 = value);

    // Act
    viewModel.onDispose();

    // Assert
    expect(int1, -1);
  });
}
