import 'dart:ui';

class WorkflowCancelledException implements Exception {
  final String message;
  WorkflowCancelledException([this.message = 'Workflow was cancelled by the user.']);
  
  @override
  String toString() => 'WorkflowCancelledException: $message';
}

class CancellationToken {
  bool _isCancelled = false;
  final List<VoidCallback> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw WorkflowCancelledException();
    }
  }

  void onCancel(VoidCallback callback) {
    if (_isCancelled) {
      callback();
    } else {
      _listeners.add(callback);
    }
  }
}
