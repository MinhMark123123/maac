import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A Widget class that inherits from [ConsumerStatefulWidget] but wrap [HookConsumerWidget] so we can use hooks and listen to providers
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
abstract class ConsumerViewModelWidget<T extends ViewModel>
    extends ConsumerStatefulWidget {
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

  ///The [awake] method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of
  ///the ViewModel.
  ///This will be helpful for setting up the necessary data.
  void awake(WidgetRef ref, T viewModel) {}

  ///A utility method to get the instance of the existing viewModel provided at [viewModelProvider]
  T viewModel(WidgetRef ref) => ref.watch(viewModelProvider());

  ///The [build] method is where you build the interface
  Widget buildWidget(BuildContext context, WidgetRef ref, T viewModel);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _BindViewModelWidgetState<T>();
  }
}

class _BindViewModelWidgetState<T extends ViewModel>
    extends ConsumerState<ConsumerViewModelWidget<T>> {
  final _visibilityDetectorKey = UniqueKey();
  final _uniqueKey = UniqueKey().toString();

  T _watchViewModel(WidgetRef ref) => ref.watch(widget.viewModelProvider());

  T _readViewModel(WidgetRef ref) => ref.read(widget.viewModelProvider());
  late LifeCycleManager lifeCycleManager;

  @override
  void initState() {
    super.initState();
    final viewModel = _readViewModel(ref);
    widget.awake(ref, viewModel);
    lifeCycleManager = LifeCycleManager([viewModel]);
    lifeCycleManager.registerWidgetBindLifecycle(_uniqueKey);
    lifeCycleManager.initState(_uniqueKey);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _watchViewModel(ref);
    if (viewModel.isBoundLifeCycle) {
      return _buildHookConsumer(viewModel);
    }
    return VisibilityDetector(
      onVisibilityChanged: (info) {
        lifeCycleManager.onVisibilityChanged(info);
      },
      key: _visibilityDetectorKey,
      child: _buildHookConsumer(viewModel),
    );
  }

  HookConsumer _buildHookConsumer(viewModel) {
    return HookConsumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return widget.buildWidget(context, ref, viewModel);
      },
    );
  }

  @override
  void activate() {
    lifeCycleManager.widgetActivate(_uniqueKey);
    super.activate();
  }

  @override
  void didChangeDependencies() {
    lifeCycleManager.widgetDidChangeDependencies(_uniqueKey);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    lifeCycleManager.widgetDeActivate(_uniqueKey);
    super.deactivate();
  }

  @override
  void didUpdateWidget(covariant ConsumerViewModelWidget<T> oldWidget) {
    lifeCycleManager.widgetDidUpdateWidget(
      lifeOwnerKey: _uniqueKey,
      widget: widget,
      oldWidget: oldWidget,
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    lifeCycleManager.dispose(_uniqueKey);
    super.dispose();
  }
}
