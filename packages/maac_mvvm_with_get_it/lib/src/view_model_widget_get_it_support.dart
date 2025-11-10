import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_with_get_it/src/get.dart';

/// An abstract widget that is tied to a single ViewModel, managed via `GetIt`.
/// This widget automatically handles the lifecycle of the ViewModel within
/// a `GetIt` dependency injection scope.
///
/// The ViewModel is created using the `injectViewModel()` method and is
/// registered within the `GetIt` container. This ensures that the ViewModel is
/// properly scoped and available for injection.
///
/// This class can be extended to create widgets that are bound to a single
/// ViewModel instance.
abstract class DependencyViewModelWidget<T extends ViewModel> extends ViewModelWidget<T> {
  const DependencyViewModelWidget({super.key});

  @override
  // ignore:
  ViewState createState() => _BindViewModelWidgetState<T>();

  @override
  T createViewModel() => injectViewModel();
}

/// An abstract widget that is tied to multiple ViewModels, managed via `GetIt`.
/// This widget automatically handles the lifecycle of the ViewModels within
/// a `GetIt` dependency injection scope.
///
/// The ViewModels are created by overriding the `createViewModels()` method and
/// are registered/unregistered as necessary. This class provides a template for
/// working with multiple ViewModels in a single widget.
///
/// This class can be extended to create widgets that are bound to multiple
/// ViewModel instances.
abstract class DependencyViewModelsWidget extends ViewModelsWidget {
  const DependencyViewModelsWidget({super.key});

  @override
  // ignore:
  ViewState createState() => _BindViewModelsWidgetState();

  /// Registers a ViewModel in the `GetIt` container.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// void registerViewModel(ViewModel viewModel) {
  ///   if (viewModel is MockExampleViewModel) {
  ///     GetIt.instance.registerSingleton(viewModel);
  ///     return;
  ///   }
  ///   if (viewModel is MockExampleSecondViewModel) {
  ///     GetIt.instance.registerSingleton(viewModel);
  ///   }
  /// }
  /// ```
  void registerViewModel(ViewModel viewModel);

  /// Unregisters a ViewModel from the `GetIt` container.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// void unRegisterViewModel(ViewModel viewModel) {
  ///   if (viewModel is MockExampleViewModel) {
  ///     GetIt.instance.unregister(instance: viewModel);
  ///     return;
  ///   }
  ///   if (viewModel is MockExampleSecondViewModel) {
  ///     GetIt.instance.unregister(instance: viewModel);
  ///   }
  /// }
  /// ```
  void unRegisterViewModel(ViewModel viewModel);
}

/// A state class for `DependencyViewModelWidget`. This state binds a single
/// ViewModel to the widget and manages its lifecycle using the `GetIt` dependency
/// injection container.
///
/// This class ensures that:
/// - The ViewModel is properly registered in a `GetIt` scope.
/// - The widget's `awake` method is called with the proper context.
/// - The ViewModel is unregistered when the widget is disposed.
class _BindViewModelWidgetState<T extends ViewModel> extends BaseViewModelState<DependencyViewModelWidget> with _ViewModelGetMixin {
  @override
  List<ViewModel> bindViewModels() => [widget.createViewModel()];

  get viewModel => viewModels.first;

  @override
  void aWake() {
    super.aWake();
    // Register each ViewModel in the GetIt container
    handleRegisterViewModel<T>(viewModel: viewModel);
    // Call the widget's awake method with context and lifecycle manager.
    widget.awake(
      WrapperContext(context: context, lifeCycleManager: lifeCycleManager),
      GetIt.instance.get<T>(),
    );
  }

  @override
  Widget get childBuilder => widget.build(context, viewModel);

  @override
  void dispose() {
    super.dispose();
    handleUnRegisterViewModel<T>(instance: viewModel);
  }
}

/// A state class for `DependencyViewModelsWidget`. This state binds multiple
/// ViewModels to the widget and manages their lifecycle using the `GetIt` dependency
/// injection container.
///
/// This class ensures that:
/// - All ViewModels are properly registered in a `GetIt` scope.
/// - The widget's `awake` method is called with the proper context.
/// - All ViewModels are unregistered when the widget is disposed.
class _BindViewModelsWidgetState extends BaseViewModelState<DependencyViewModelsWidget> {
  @override
  List<ViewModel> bindViewModels() => widget.createViewModels();

  @override
  void aWake() {
    super.aWake();
    // Register each ViewModel in the GetIt container
    for (var viewModel in viewModels) {
      widget.registerViewModel(viewModel);
    }
    // Call the widget's awake method
    widget.awake(
      WrapperContext(context: context, lifeCycleManager: lifeCycleManager),
      viewModels,
    );
  }

  @override
  Widget get childBuilder => widget.build(context, viewModels);

  @override
  void dispose() {
    // Unregisters all ViewModels and disposes of this state.
    for (var viewModel in viewModels) {
      widget.unRegisterViewModel(viewModel);
    }
    super.dispose();
  }
}

/// A mixin that provides utility methods for managing ViewModels within the `GetIt`
/// dependency injection container. This mixin simplifies the process of registering
/// and unregistering ViewModels.
mixin _ViewModelGetMixin {
  /// Registers a ViewModel in the `GetIt` container as a singleton if it is not
  /// already registered.
  void handleRegisterViewModel<T extends ViewModel>({required T viewModel}) {
    // Unregister any existing instance of the same type before registering a new one.
    // This handles cases like hot reload or navigation where a new widget/viewModel
    // replaces an old one.
    if (GetIt.instance.isRegistered<T>()) {
      GetIt.instance.unregister<T>();
    }
    GetIt.instance.registerSingleton<T>(viewModel);
  }

  /// Unregisters a ViewModel from the `GetIt` container.
  void handleUnRegisterViewModel<T extends ViewModel>({required T instance}) {
    if (GetIt.instance.isRegistered<T>(instance: instance)) {
      GetIt.instance.unregister<T>(instance: instance);
    }
  }
}
