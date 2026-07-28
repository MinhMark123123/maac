import 'package:flutter/foundation.dart';

import 'cancellation_token.dart';
import 'flow_context.dart';
import 'result.dart';
import 'runner.dart';
import 'workflow_runner_factory.dart';

/// Governs when a [SharedWorkflowRunner] session's [SharedWorkflowRunner.isSessionActive]
/// signal closes, once multiple callers have [SharedWorkflowRunner.join]ed
/// one shared run.
///
/// None of these rules change *when the underlying run actually finishes* —
/// there is exactly one physical run per session, and every joiner's
/// [SessionJoinHandle.result] is the identical `Future`, resolving at one
/// instant for everyone. They only govern the separate, UI-facing
/// [SharedWorkflowRunner.isSessionActive] signal (e.g. a shared loading
/// indicator) — and, for [overrideByLatest] and [firstWins], whether closing
/// that signal also cancels the run while it's still in flight. **If any
/// joiner needs the real success/failure outcome rather than just an
/// "something happened" signal, use [waitAll]** — under the other two
/// rules, an early close cancels the shared run for every joiner still
/// attached, turning their [SessionJoinHandle.result] into
/// [WorkflowCancelled] regardless of how the work would otherwise have
/// turned out.
enum JoinCompletionRule {
  /// Reference-counted: the session stays active until every joiner that
  /// attached has called [SessionJoinHandle.leave] — a joiner who never
  /// calls it leaves the session open forever. This is the only rule under
  /// which the run is never cut short by a joiner leaving early.
  waitAll,

  /// The most recently joined caller owns the session's lifetime. When
  /// *that* joiner leaves, the session closes immediately — cancelling the
  /// run if it's still in flight — regardless of whether earlier joiners
  /// are still attached. An earlier joiner's [SessionJoinHandle.leave] is a
  /// no-op.
  overrideByLatest,

  /// The very first [SessionJoinHandle.leave] call, from any joiner, closes
  /// the session immediately and cancels the run if it's still in flight.
  /// Every other joiner's `leave()` becomes a no-op the instant that happens.
  firstWins,
}

class _Session<TContext extends FlowContext> {
  final WorkflowRunner<TContext> runner;
  final CancellationToken token;
  final Future<WorkflowResult<TContext>> result;
  final JoinCompletionRule rule;

  int _nextJoinerId = 0;
  final Set<int> _activeJoinerIds = {};
  int? _latestJoinerId;
  bool _closed = false;

  _Session({required this.runner, required this.token, required this.result, required this.rule});
}

/// Implements the `joinOrCreate` concurrency strategy: if no session is
/// active, [join] starts a new one via [createRunner]; if one is already in
/// flight, [join] merges into it instead of starting a second physical run
/// — avoiding duplicate work and UI flicker for shared resources like a
/// global loading indicator.
///
/// Every joiner of the same session shares the identical
/// [SessionJoinHandle.result] `Future`. [rule] governs when
/// [isSessionActive] closes once multiple joiners are attached — see
/// [JoinCompletionRule].
class SharedWorkflowRunner<TContext extends FlowContext> {
  final WorkflowRunnerFactory<TContext> createRunner;
  final JoinCompletionRule rule;

  final ValueNotifier<bool> _isSessionActive = ValueNotifier(false);
  _Session<TContext>? _session;

  SharedWorkflowRunner({required this.createRunner, required this.rule});

  /// True while a session is active — bind a shared loading indicator to
  /// this. The same instance for the lifetime of this [SharedWorkflowRunner],
  /// reused across however many sessions come and go.
  ValueListenable<bool> get isSessionActive => _isSessionActive;

  /// Starts a new session if none is active, or joins the one already in
  /// flight — in which case [context] is never used; the already-running
  /// session's own context is what's actually executing.
  SessionJoinHandle<TContext> join(TContext context) {
    final session = _session ?? _startSession(context);
    return _attachNewJoiner(session);
  }

  /// Releases the underlying `ValueNotifier`. Call once this runner is no
  /// longer needed, e.g. from a ViewModel's `onDispose`.
  void dispose() => _isSessionActive.dispose();

  _Session<TContext> _startSession(TContext context) {
    final runner = createRunner();
    final token = CancellationToken();
    final result = runner.run(context, cancellationToken: token);
    final session = _Session<TContext>(runner: runner, token: token, result: result, rule: rule);
    _session = session;
    _isSessionActive.value = true;
    return session;
  }

  SessionJoinHandle<TContext> _attachNewJoiner(_Session<TContext> session) {
    final id = session._nextJoinerId++;
    session._activeJoinerIds.add(id);
    session._latestJoinerId = id;
    return SessionJoinHandle<TContext>._(
      result: session.result,
      isSessionActive: _isSessionActive,
      onLeave: () => _leave(session, id),
    );
  }

  void _leave(_Session<TContext> session, int joinerId) {
    if (session._closed) return;
    session._activeJoinerIds.remove(joinerId);
    final shouldClose = switch (session.rule) {
      JoinCompletionRule.waitAll => session._activeJoinerIds.isEmpty,
      JoinCompletionRule.overrideByLatest => joinerId == session._latestJoinerId,
      JoinCompletionRule.firstWins => true,
    };
    if (shouldClose) _closeSession(session);
  }

  void _closeSession(_Session<TContext> session) {
    session._closed = true;
    session.token.cancel();
    if (identical(_session, session)) {
      _session = null;
      _isSessionActive.value = false;
    }
  }
}

/// A single caller's attachment to a [SharedWorkflowRunner] session,
/// returned by [SharedWorkflowRunner.join].
class SessionJoinHandle<TContext extends FlowContext> {
  /// The session's one physical run outcome — identical `Future` instance
  /// for every joiner of the same session.
  final Future<WorkflowResult<TContext>> result;

  /// Same instance as [SharedWorkflowRunner.isSessionActive].
  final ValueListenable<bool> isSessionActive;

  final void Function() _onLeave;
  bool _hasLeft = false;

  SessionJoinHandle._({required this.result, required this.isSessionActive, required void Function() onLeave}) : _onLeave = onLeave;

  /// Signals this joiner is done with the session. Idempotent — a second
  /// call on the same handle is a no-op. See [JoinCompletionRule] for
  /// exactly what effect this has on [isSessionActive] and the underlying
  /// run.
  void leave() {
    if (_hasLeft) return;
    _hasLeft = true;
    _onLeave();
  }
}
