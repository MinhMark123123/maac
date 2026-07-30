import 'package:meta/meta.dart';

/// A key-value store shared across every step of a workflow, enforcing
/// "scoped immutability": once a key has been written by a step, only that
/// same step may write it again (e.g. from its own `rollback`) — every
/// other step gets read-only access to it.
///
/// Concrete flows don't need to subclass this — attach typed, ergonomic
/// accessors via a Dart `extension` instead (see the `signup_flow` example),
/// keeping `FlowContext` itself a plain, reusable store.
class FlowContext {
  final Map<String, Object?> _data = {};
  final Map<String, String> _writtenBy = {};
  String? _activeStepId;
  void Function(String key, Object? value, String? writerStepId)? _onWrite;

  /// Set by [WorkflowRunner] immediately before/after a step is the active
  /// one (forward execute or rollback). Not for application code.
  @internal
  void setActiveStepId(String? stepId) => _activeStepId = stepId;

  /// Set by [WorkflowRunner] for the duration of a `run()` call, when a
  /// `listener` is configured, so its `onContextWrite` fires for every
  /// successful [write]. Not for application code.
  @internal
  void setWriteInterceptor(void Function(String key, Object? value, String? writerStepId)? onWrite) => _onWrite = onWrite;

  /// Reads [key]. Always unrestricted — scoped immutability only gates
  /// writes, not reads.
  T? read<T>(String key) => _data[key] as T?;

  /// Whether [key] has ever been written.
  bool has(String key) => _data.containsKey(key);

  /// Writes [key].
  ///
  /// While a step is active, a key already written by a *different* step is
  /// read-only and this throws [StateError] — later steps may read data
  /// earlier steps produced, but never overwrite it. A step overwriting its
  /// own key (e.g. from its own `rollback`) is always allowed.
  ///
  /// Writes made with no step active (before a run starts, or between runs
  /// — e.g. a ViewModel seeding input) are always allowed and reset that
  /// key's ownership, since scoped immutability is a rule between steps,
  /// not a restriction on the code that configures a run.
  void write<T>(String key, T value) {
    if (_activeStepId == null) {
      _data[key] = value;
      _writtenBy.remove(key);
      _onWrite?.call(key, value, null);
      return;
    }
    final owner = _writtenBy[key];
    if (owner != null && owner != _activeStepId) {
      throw StateError('Key "$key" was already written by step "$owner"; step "$_activeStepId" cannot overwrite it (scoped immutability).');
    }
    _data[key] = value;
    _writtenBy[key] = _activeStepId!;
    _onWrite?.call(key, value, _activeStepId);
  }
}
