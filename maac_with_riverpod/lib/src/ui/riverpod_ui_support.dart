import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maac_core/maac_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

abstract class ConsumerViewModelWidget<T extends ViewModel> extends HookConsumerWidget  {
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
    useEffect(
      () {
        aWake(ref, viewModel);
        viewModel.registerWidgetBindLifecycle(this);
        executeCondition(viewModel.isValidLifeCycleHolder(this), () => viewModel.onInitState());
        return () {
          executeCondition(viewModel.isValidLifeCycleHolder(this), () => viewModel.onDispose());
        };
      },
      [],
    );
    return buildWidget(context, ref, viewModel);
  }
}
