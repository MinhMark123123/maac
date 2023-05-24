import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useOnDeActive(Function() onDeActive, [List<Object?>? keys]) {
  use(_OnDeActiveHook(onDeActive, keys));
}

class _OnDeActiveHook extends Hook<void> {
  const _OnDeActiveHook(this.onDeActive, [List<Object?>? keys])
      : super(keys: keys);

  final Function() onDeActive;

  @override
  _EffectHookState createState() => _EffectHookState();
}

class _EffectHookState extends HookState<void, _OnDeActiveHook> {
  @override
  void deactivate() {
    hook.onDeActive.call();
    super.deactivate();
  }

  @override
  String get debugLabel => 'useEffect';

  @override
  bool get debugSkipValue => true;

  @override
  void build(BuildContext context) {}
}
