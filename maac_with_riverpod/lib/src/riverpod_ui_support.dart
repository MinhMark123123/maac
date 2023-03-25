import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_core/maac_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maac_with_riverpod/src/hook_deactive.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class ConsumerViewModelWidget<T extends ViewModel> extends HookConsumerWidget {
  const ConsumerViewModelWidget({super.key});

  AutoDisposeProvider<T> viewModelProvider();

  T _watchViewModel(WidgetRef ref) => ref.watch(viewModelProvider());

  void aWake(WidgetRef ref, T viewModel) {}

  T viewModel(WidgetRef ref) => ref.read(viewModelProvider());

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
        aWake(ref, viewModel);
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
