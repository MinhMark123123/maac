# maac_mvvm_generator

`maac_mvvm_generator` is a powerful code generator designed for the [maac_mvvm](https://pub.dev/packages/maac_mvvm) package.

## Description

`maac_mvvm_generator` streamlines the development process by automatically generating necessary code, thereby significantly reducing boilerplate when working with the [maac_mvvm](https://pub.dev/packages/maac_mvvm) package.

## Features

*   Reduces boilerplate code for creating ViewModel with maac_mvvm components.
*   Easy integration with the [maac_mvvm](https://pub.dev/packages/maac_mvvm) package.

![Coverage](coverage_badge.svg)
    

## Getting started

1.  Add `maac_mvvm_annotation` to your `dependencies:`
```
flutter pub add maac_mvvm_annotation
```

2.  Add `maac_mvvm_generator` to your `dev_dependencies`:
```
flutter pub add dev:maac_mvvm_generator
```
    

## Usage
First let change current code : 
```dart 
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
//define part generated
part 'example_view_model.g.dart';

BindableViewModel()
class ExampleViewModel extends ViewModel { 

  late final _count = 0.mutableData(this);

  StreamData<int> get count => _count.streamData;
  
  void incrementCounter() => _count.postValue(_count.data + 1);
}

````

to 

```dart
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

part 'example_view_model.g.dart';

@BindableViewModel()
class ExampleViewModel extends ViewModel {
  @Bind()
  late final _count = 0.mutableData(this);

  void incrementCounter() => _count.postValue(_count.data + 1);
}
```

then run : 
```
flutter pub run build_runner build --delete-conflicting-outputs
```
The `StreamData<int> get count => _count.streamData;` will be generated in `example_view_model.g.dart`.
