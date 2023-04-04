import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_with_riverpod/src/hook_deactive.dart';
import 'package:visibility_detector/visibility_detector.dart';
/// A Widget class that inherits from [HookConsumerWidget] and can use hooks and listen to providers
/// while binding to the corresponding ViewModel.
///
/// ```dart
/// class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
///   const ExamplePage({super.key});
///
///   @override
///   AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;
///
///   @override
///   Widget buildWidget(BuildContext context, WidgetRef ref, ExamplePageViewModel viewModel) {
///     final counter = ref.watch(viewModel.counterSelector);
///     return BuildYourPageWidget();
///   }
/// }
/// ```
abstract class ConsumerViewModelWidget<T extends ViewModel> extends HookConsumerWidget {
  const ConsumerViewModelWidget({super.key});

  /// Provides the current page's ViewModel provider. This provider must be declared in an [AutoDisposeProvider]
  /// to ensure that the ViewModel will be disposed and there will be no memory leaks when the corresponding binding widget is removed from the widget tree.
  ///
  /// ```dart
  /// final exampleViewModelProvider = Provider.autoDispose<ExamplePageViewModel>((ref) {
  ///   return ExamplePageViewModel(uiState: ref.watch(_exampleUIStateProvider.notifier));
  /// });
  /// class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
  ///   const ExamplePage({super.key});
  ///
  ///   @override
  ///   AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;
  ///}
  /// ```
  AutoDisposeProvider<T> viewModelProvider();

  T _watchViewModel(WidgetRef ref) => ref.watch(viewModelProvider());

  ///The [awake] method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of
  ///the ViewModel.
  ///This will be helpful for setting up the necessary data.
  void awake(WidgetRef ref, T viewModel) {}

  ///A utility method to get the instance of the existing viewModel provided at [viewModelProvider]
  T viewModel(WidgetRef ref) => _watchViewModel(ref);

  ///The [build] method is where you build the interface
  Widget buildWidget(BuildContext context, WidgetRef ref, T viewModel);

  @override
  //ignore
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = _watchViewModel(ref);
    if (viewModel.isBoundLifeCycle) {
      return buildWidget(context, ref, viewModel);
    }
    final visibilityDetectorKey = useMemoized(() => UniqueKey());
    final lifeCycleManager = useMemoized(() => LifeCycleManager([viewModel]));
    useEffect(
      () {
        awake(ref, viewModel);
        lifeCycleManager.registerWidgetBindLifecycle(this);
        lifeCycleManager.initState(this);
        useOnDeActive(() => lifeCycleManager.onDeActive(this));
        return () {
          lifeCycleManager.dispose(this);
        };
      },
      [],
    );
    return VisibilityDetector(
      key: visibilityDetectorKey,
      onVisibilityChanged: (info) => lifeCycleManager.onVisibilityChanged(info, this),
      child: buildWidget(context, ref, viewModel),
    );
  }
}
