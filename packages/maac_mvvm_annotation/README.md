<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
# maac_mvvm_annotation
The `maac_mvvm_annotation` package is part of the [maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm). This annotation package is the backbone of the [maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm), providing annotations that help reduce boiterlplate code by generator code extension.
---
![MAAC_MVVM_ANNOTATION](https://github.com/MinhMark123123/maac/blob/main/resources/mvvm.png)

---

## Features

*   **@BindableViewModel:** Annotate classes as ViewModels, signifying their role in managing the UI's state and logic and containt fields annotated with @Bind.
*   **@Bind:** This annotation is signals that the field should be
automatically bound to a corresponding property in the that is annotated with @BindableViewModel.
## Getting Started 🏁
### Prerequisites
Before you begin, ensure that you have Flutter SDK installed in your development environment.
### Installation
Add `maac_mvvm_annotation` to your `pubspec.yaml` file:

## Usage

add the import statement to your file:

```dart
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
```
