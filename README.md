[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
# maac
![maac_mvvm](https://github.com/MinhMark123123/maac/blob/main/resources/mvvm.png)

| Package                 | Version                                                                                                                                                                                          |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| maac_mvvm               | [![pub package](https://img.shields.io/pub/v/maac_mvvm.svg?label=maac_mvvm&color=blue)](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm)                                     |
| maac_mvvm_with_get_it   | [![pub package](https://img.shields.io/pub/v/maac_mvvm_with_get_it.svg?label=maac_mvvm_with_get_it&color=blue)](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it) |
| maac_mvvm_with_riverpod | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=maac_mvvm_with_riverpod&color=blue)](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_riverpod)          |
| maac_mvvm_annotation | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=maac_mvvm_annotation&color=blue)](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_annotation)          |
| maac_mvvm_generator | [![pub package](https://img.shields.io/pub/v/riverpod.svg?label=maac_mvvm_generator&color=blue)](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_generator)          |

**A collection of MVVM implementations using different state management solutions.**

This repository contains three packages, each demonstrating a different approach to implementing the Model-View-ViewModel (MVVM) architecture:

* **[maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm):** A basic MVVM implementation without any external state management libraries.
* **[maac_mvvm_with_get_it](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it):** MVVM with dependency injection using the `get_it` package.
* **[maac_mvvm_with_riverpod](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_riverpod):** MVVM with state management using the `riverpod` package.
* **[maac_mvvm_annotation](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_annotation):** This annotation package is the backbone of the [maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm), providing annotations that help reduce boiterlplate code by generator code extension
* **[maac_mvvm_generator](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_generator):** This is a code generator designed for the [maac_mvvm](https://pub.dev/packages/maac_mvvm) package.


***Why This Project?***

As many Android developers transition to Flutter, it can be challenging to adapt to the new paradigms and best practices while retaining familiarity with architectural patterns. This project aims to make that transition easier by:

- Keeping Syntax Familiar: This project uses patterns similar.
- Simple Learning Approach: By providing straightforward examples without complex or overwhelming code, each package keeps learning simple, making it easier for developers to understand Flutter's approach to UI and state management.

***What is MVVM?***

Model-View-ViewModel (MVVM) is an architectural pattern that helps separate the application's user interface (UI) from the business logic. The pattern divides an application into three primary components:

- Model: Manages the data and business logic. It represents the domain of the data.
- View: Displays the UI and observes changes in the ViewModel.
- ViewModel: Acts as a bridge between the Model and the View, holding state-data and exposing it to the View in a format that can be consumed.

***MVVM Implementations in This Repository***

Each package demonstrates a different approach to MVVM:

- [maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm): Basic MVVM implementation with no external state management libraries. 

- [maac_mvvm_with_get_it](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it): Implements dependency injection with get_it for better separation of concerns, allowing for more scalable and testable code.

- [maac_mvvm_with_riverpod](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_riverpod): Uses riverpod, a powerful state management solution, which provides more granular control and makes it easier to handle complex state changes and reactive updates in the app.

***Choosing a State Management Solution***

This project allows you to compare and choose an MVVM implementation with the state management solution that best fits your project's needs:

- Basic ([maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm)): Ideal for small apps or prototyping. Minimal overhead and dependencies.
- Implement with get_it (Dependency Injection)([maac_mvvm_with_get_it](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it)): Recommended for medium-to-large apps where you want to keep services and dependencies loosely coupled.
- Implement with riverpod([maac_mvvm_with_riverpod](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_riverpod)): If you are familiar with Riverpod, Riverpod offers excellent performance and flexibility.

**Prerequisites**

Flutter SDK: Ensure you have Flutter installed on your system. For installation instructions, please visit flutter.dev.
Dependencies: Each package may have unique dependencies, especially for get_it and riverpod packages. Run flutter pub get in each package to fetch dependencies.

**Install**

- Install [maac_mvvm](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm) package from pub: ```flutter pub add maac_mvvm```
- Install [maac_mvvm_with_get_it](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it) from pub: ```flutter pub add maac_mvvm_with_get_it```
- Install [maac_mvvm_with_riverpod](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_riverpod) package from pub: ```flutter pub add maac_mvvm_with_riverpod```
- Install [maac_mvvm_annotation](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_annotation) package from pub: ```flutter pub add maac_mvvm_annotation```
- Install [maac_mvvm_generator](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_generator) package from pub: ```flutter pub add dev:maac_mvvm_generator```

**Contributing**

Contributions are welcome! Please submit a pull request if you'd like to make improvements to this project.

