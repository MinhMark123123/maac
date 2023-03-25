import 'dart:async';

abstract class Flow<Result, Param> {
  final Param? param;
  Completer<Result?>? _completer = Completer<Result?>();

  Flow({required this.param});

  Future<void> setupFlow();

  Future<Result?> execute() async{
    if (_completer?.isCompleted ?? true) {
      _completer = Completer<Result?>();
    }
    await setupFlow();
    return _completer!.future;
  }

  void completeFlow({Result? result}) {
    if (_completer?.isCompleted ?? true) {
      return;
    }
    _completer?.complete(result);
  }
}
