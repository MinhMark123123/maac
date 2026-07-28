import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maac_workflow/maac_workflow.dart';

class TestContext extends FlowContext {
  final List<String> logs = [];
  bool hasFeatureX = false;
  bool shouldFailStep = false;
  int retryAttemptsCount = 0;
}

/// An interactive step that logs on activate/submit/fail and records
/// whether it was ever cleaned up via `onDeactivateOrCancel`.
class InteractiveTestStep extends InteractiveStep<TestContext, String?> {
  final String name;
  bool deactivated = false;

  InteractiveTestStep(this.name);

  @override
  String get id => name;

  @override
  void onActivate(TestContext context, CancellationToken token) {
    context.logs.add('activate:$name');
  }

  @override
  StepResult onSubmit(TestContext context, String? input, CancellationToken token) {
    context.logs.add('submit:$name${input != null ? ":$input" : ''}');
    return const StepSuccess();
  }

  @override
  StepResult onFail(TestContext context, Object error, StackTrace stackTrace, CancellationToken token) {
    context.logs.add('fail:$name');
    return StepFailure(error, stackTrace);
  }

  @override
  Future<void> onDeactivateOrCancel(TestContext context) async {
    deactivated = true;
    context.logs.add('deactivate:$name');
  }
}

class LogStep extends WorkflowStep<TestContext> {
  final String name;

  LogStep(this.name);

  @override
  String get id => name;

  @override
  Future<StepResult> execute(TestContext context, CancellationToken token) async {
    context.logs.add('execute:$name');
    return const StepSuccess();
  }

  @override
  Future<void> rollback(TestContext context) async {
    context.logs.add('rollback:$name');
  }
}

class ConditionalLogStep extends LogStep {
  ConditionalLogStep(super.name);

  @override
  Future<bool> canRun(TestContext context) async {
    return context.hasFeatureX;
  }
}

class FailingStep extends WorkflowStep<TestContext> {
  @override
  String get id => 'failing';

  @override
  Future<StepResult> execute(TestContext context, CancellationToken token) async {
    context.logs.add('execute:failing');
    return StepFailure(Exception('execution failed'));
  }

  @override
  Future<void> rollback(TestContext context) async {
    context.logs.add('rollback:failing');
  }
}

/// A step that never completes on its own — only when its token is cancelled.
/// Mirrors the "watch a stream until cancelled" pattern documented in the README.
class WaitForCancelStep extends WorkflowStep<TestContext> {
  final String name;

  WaitForCancelStep(this.name);

  @override
  String get id => name;

  @override
  Future<StepResult> execute(TestContext context, CancellationToken token) {
    context.logs.add('execute:$name');
    final completer = Completer<StepResult>();
    token.onCancel(() {
      context.logs.add('cancelled:$name');
      if (!completer.isCompleted) completer.complete(const StepSuccess());
    });
    return completer.future;
  }
}

/// Records every `onContextWrite` call it receives, in order.
class RecordingListener extends WorkflowListener<TestContext> {
  final List<(String, Object?, String?)> writes = [];

  @override
  void onContextWrite(String key, Object? value, String? writerStepId, TestContext context) {
    writes.add((key, value, writerStepId));
  }
}

/// A step that takes [delay] to complete, and records whether its token was
/// cancelled while it was still running.
class SlowStep extends WorkflowStep<TestContext> {
  final Duration delay;
  bool tokenCancelledDuringExecute = false;

  SlowStep(this.delay);

  @override
  String get id => 'slow';

  @override
  Future<StepResult> execute(TestContext context, CancellationToken token) {
    context.logs.add('execute:slow');
    final completer = Completer<StepResult>();
    Timer(delay, () {
      if (!completer.isCompleted) completer.complete(const StepSuccess());
    });
    token.onCancel(() => tokenCancelledDuringExecute = true);
    return completer.future;
  }
}

class RetryableStep extends WorkflowStep<TestContext> {
  @override
  String get id => 'retryable';

  @override
  Future<StepResult> execute(TestContext context, CancellationToken token) async {
    context.retryAttemptsCount++;
    context.logs.add('execute:retryable-$context.retryAttemptsCount');
    if (context.shouldFailStep) {
      return StepFailure(Exception('network error'));
    }
    return const StepSuccess();
  }
}

void main() {
  group('CancellationToken Tests', () {
    test('Should register listener and trigger cancellation', () {
      final token = CancellationToken();
      var cancelled = false;
      token.onCancel(() {
        cancelled = true;
      });

      expect(token.isCancelled, isFalse);
      token.cancel();
      expect(token.isCancelled, isTrue);
      expect(cancelled, isTrue);
    });

    test('Should throw exception when throwIfCancelled is called', () {
      final token = CancellationToken();
      expect(() => token.throwIfCancelled(), returnsNormally);
      token.cancel();
      expect(() => token.throwIfCancelled(), throwsA(isA<WorkflowCancelledException>()));
    });
  });

  group('WorkflowRunner Execution Tests', () {
    test('Should run steps sequentially and succeed', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), LogStep('step2')]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:step2']));
      expect(result.history.length, equals(4));
      expect(result.history[0].stepId, equals('step1'));
      expect(result.history[0].status, equals(StepStatus.running));
    });

    test('Should rollback in LIFO order when a step fails', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), LogStep('step2'), FailingStep(), LogStep('step3')]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      final failure = result as WorkflowFailure<TestContext>;
      expect(failure.failedStepId, equals('failing'));

      // step1 and step2 should be executed, then failing, then rollback step2 and step1
      expect(context.logs, equals(['execute:step1', 'execute:step2', 'execute:failing', 'rollback:step2', 'rollback:step1']));
    });
  });

  group('Conditional & Composite Steps Tests', () {
    test('Should skip step if condition is not met', () async {
      final context = TestContext()..hasFeatureX = false;
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), ConditionalLogStep('conditional_step'), LogStep('step2')]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:step2']));
      expect(result.history[2].status, equals(StepStatus.skipped));
    });

    test('Should execute step if condition is met', () async {
      final context = TestContext()..hasFeatureX = true;
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), ConditionalLogStep('conditional_step'), LogStep('step2')]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:conditional_step', 'execute:step2']));
    });

    test('Should execute conditional wrapper declarative format', () async {
      final context = TestContext()..hasFeatureX = false;
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          ConditionalStep(id: 'cond', condition: (ctx) => ctx.hasFeatureX, step: LogStep('inner_step')),
          LogStep('step2'),
        ],
      );

      final result = await runner.run(context);
      expect(context.logs, equals(['execute:step1', 'execute:step2']));
    });
  });

  group('RetryDecorator Tests', () {
    test('Should retry failing step and fail if error persists', () async {
      final context = TestContext()..shouldFailStep = true;
      final runner = WorkflowRunner<TestContext>(
        steps: [RetryStepDecorator(step: RetryableStep(), maxAttempts: 3, initialDelay: Duration.zero)],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(context.retryAttemptsCount, equals(3));
    });

    test('Should retry failing step and succeed when failure resolves', () async {
      // In a real scenario, we could mock the resolution. Let's verify it retries.
      final context = TestContext()..shouldFailStep = false;
      final runner = WorkflowRunner<TestContext>(
        steps: [RetryStepDecorator(step: RetryableStep(), maxAttempts: 3, initialDelay: Duration.zero)],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.retryAttemptsCount, equals(1));
    });
  });

  group('TimeoutStepDecorator Tests', () {
    test('Should fail with TimeoutException and cancel the step when it exceeds the timeout', () async {
      final context = TestContext();
      final slowStep = SlowStep(const Duration(milliseconds: 200));
      final runner = WorkflowRunner<TestContext>(
        steps: [TimeoutStepDecorator(step: slowStep, timeout: const Duration(milliseconds: 20))],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).error, isA<TimeoutException>());
      expect(slowStep.tokenCancelledDuringExecute, isTrue);
    });

    test('Should succeed when the step completes within the timeout', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [TimeoutStepDecorator(step: LogStep('fast'), timeout: const Duration(milliseconds: 200))],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:fast']));
    });

    test('Should not cancel the parent token when only the step times out', () async {
      final context = TestContext();
      final token = CancellationToken();
      final runner = WorkflowRunner<TestContext>(
        steps: [TimeoutStepDecorator(step: SlowStep(const Duration(milliseconds: 200)), timeout: const Duration(milliseconds: 20))],
      );

      final result = await runner.run(context, cancellationToken: token);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(token.isCancelled, isFalse);
    });
  });

  group('WorkflowStepGroup Tests', () {
    test('Should run all inner steps as if the group were a single successful step', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('before'),
          WorkflowStepGroup(id: 'group', steps: [LogStep('inner1'), LogStep('inner2')]),
          LogStep('after'),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:before', 'execute:inner1', 'execute:inner2', 'execute:after']));
    });

    test('Should report the group id as failedStepId, after the sub-workflow rolls back its own steps', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('before'),
          WorkflowStepGroup(id: 'group', steps: [LogStep('inner1'), FailingStep()]),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).failedStepId, equals('group'));
      expect(
        context.logs,
        equals([
          'execute:before',
          'execute:inner1',
          'execute:failing',
          'rollback:inner1', // rolled back inside the sub-workflow
          'rollback:before', // rolled back by the parent workflow
        ]),
      );
    });

    test('Should rollback its inner steps in LIFO order when a later sibling step fails', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          WorkflowStepGroup(id: 'group', steps: [LogStep('inner1'), LogStep('inner2')]),
          FailingStep(),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).failedStepId, equals('failing'));
      expect(context.logs, equals(['execute:inner1', 'execute:inner2', 'execute:failing', 'rollback:inner2', 'rollback:inner1']));
    });
  });

  group('WorkflowRunner progress / current step Tests', () {
    test('Should expose an empty, current-step-less snapshot before run() is called', () {
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), LogStep('step2')]);

      expect(runner.progress.value.currentStepId, isNull);
      expect(runner.progress.value.stepStatuses, isEmpty);
    });

    test('Should track the current step and mark every step success as the workflow completes', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), LogStep('step2')]);

      final snapshots = <WorkflowProgress>[];
      runner.progress.addListener(() => snapshots.add(runner.progress.value));

      await runner.run(context);

      // First snapshot resets both steps to pending with no current step.
      expect(snapshots.first.stepStatuses, equals({'step1': StepStatus.pending, 'step2': StepStatus.pending}));
      expect(snapshots.first.currentStepId, isNull);

      // Each step was reported as the current, running step at some point.
      expect(snapshots.any((s) => s.currentStepId == 'step1' && s.statusOf('step1') == StepStatus.running), isTrue);
      expect(snapshots.any((s) => s.currentStepId == 'step2' && s.statusOf('step2') == StepStatus.running), isTrue);

      final last = runner.progress.value;
      expect(last.currentStepId, isNull);
      expect(last.statusOf('step1'), equals(StepStatus.success));
      expect(last.statusOf('step2'), equals(StepStatus.success));
    });

    test('Should mark the failed step and roll back completed steps, then clear currentStepId', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1'), FailingStep()]);

      await runner.run(context);

      final progress = runner.progress.value;
      expect(progress.currentStepId, isNull);
      expect(progress.statusOf('step1'), equals(StepStatus.rollbackSuccess));
      expect(progress.statusOf('failing'), equals(StepStatus.failed));
    });

    test('Should reset progress to pending at the start of every run() call', () async {
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1')]);
      await runner.run(TestContext());
      expect(runner.progress.value.statusOf('step1'), equals(StepStatus.success));

      final runFuture = runner.run(TestContext());
      // run() executes synchronously up to its first `await`, so the reset is
      // already visible before this second call itself is awaited.
      expect(runner.progress.value.statusOf('step1'), equals(StepStatus.pending));
      await runFuture;
      expect(runner.progress.value.statusOf('step1'), equals(StepStatus.success));
    });
  });

  group('FlowContext ownership Tests', () {
    test('write() succeeds with no active step, and resets prior ownership', () {
      final context = TestContext();
      context.write('key', 'v1');
      expect(context.read<String>('key'), equals('v1'));

      context.setActiveStepId('stepA');
      context.write('key', 'v2');
      context.setActiveStepId(null);

      // External write (no active step) is always allowed and clears
      // ownership, so a different step can freshly claim the key next.
      context.write('key', 'v3');
      expect(context.read<String>('key'), equals('v3'));

      context.setActiveStepId('stepB');
      expect(() => context.write('key', 'v4'), returnsNormally);
    });

    test('write() succeeds when the same active step re-writes its own key', () {
      final context = TestContext();
      context.setActiveStepId('stepA');
      context.write('key', 'v1');
      expect(() => context.write('key', 'v2'), returnsNormally);
      expect(context.read<String>('key'), equals('v2'));
    });

    test('write() throws StateError when a different active step overwrites an owned key', () {
      final context = TestContext();
      context.setActiveStepId('stepA');
      context.write('key', 'v1');

      context.setActiveStepId('stepB');
      expect(() => context.write('key', 'v2'), throwsA(isA<StateError>()));
    });

    test('read() of an unset key returns null', () {
      final context = TestContext();
      expect(context.read<String>('missing'), isNull);
    });

    test('A step overwriting a key owned by an earlier step surfaces as WorkflowFailure', () async {
      final context = TestContext();
      final writerStep = WorkflowStep<TestContext>.action(
        id: 'writer',
        execute: (ctx, token) async {
          ctx.write('shared', 'from-writer');
          return const StepSuccess();
        },
      );
      final conflictingStep = WorkflowStep<TestContext>.action(
        id: 'conflicting',
        execute: (ctx, token) async {
          ctx.write('shared', 'from-conflicting');
          return const StepSuccess();
        },
      );
      final runner = WorkflowRunner<TestContext>(steps: [writerStep, conflictingStep]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      final failure = result as WorkflowFailure<TestContext>;
      expect(failure.failedStepId, equals('unknown'));
      expect(failure.error, isA<StateError>());
    });

    test('WorkflowStepGroup.rollback attributes each inner step\'s write to its own id, not the group\'s', () async {
      // Without WorkflowStepGroup.rollback setting the active-step id per
      // inner step, this rollback write would see the group's id as active
      // (not 'inner1', the actual owner of 'resource') and throw StateError
      // — leaving 'resource' at its forward-execution value instead of
      // 'released'.
      final context = TestContext();
      final inner1 = WorkflowStep<TestContext>.action(
        id: 'inner1',
        execute: (ctx, token) async {
          ctx.write('resource', 'claimed-by-inner1');
          return const StepSuccess();
        },
        rollback: (ctx) async => ctx.write('resource', 'released'),
      );
      final group = WorkflowStepGroup<TestContext>(id: 'group', steps: [inner1]);
      final runner = WorkflowRunner<TestContext>(steps: [group, FailingStep()]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(context.read<String>('resource'), equals('released'));
    });
  });

  group('WorkflowRunner submit/fail StateError enforcement Tests', () {
    test('submit() throws StateError when no run is in flight', () {
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('step1')]);
      expect(() => runner.submit('step1'), throwsA(isA<StateError>()));
    });

    test('submit() throws StateError when stepId does not match the active step', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('interactive');
      final runner = WorkflowRunner<TestContext>(steps: [interactive]);
      final future = runner.run(context);
      await Future.delayed(Duration.zero);

      expect(() => runner.submit('not_the_active_step'), throwsA(isA<StateError>()));

      runner.submit('interactive');
      await future;
    });

    test('submit() throws StateError when the active step is a plain (non-interactive) step', () async {
      final context = TestContext();
      final slow = SlowStep(const Duration(milliseconds: 50));
      final runner = WorkflowRunner<TestContext>(steps: [slow]);
      final future = runner.run(context);
      await Future.delayed(Duration.zero);

      expect(() => runner.submit('slow'), throwsA(isA<StateError>()));

      await future;
    });

    test('submit()/fail() throw StateError once a step has already been resolved', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('interactive');
      final runner = WorkflowRunner<TestContext>(steps: [interactive]);
      final future = runner.run(context);
      await Future.delayed(Duration.zero);

      runner.submit('interactive');
      expect(() => runner.fail('interactive', Exception('too late')), throwsA(isA<StateError>()));

      await future;
    });
  });

  group('InteractiveStep Tests', () {
    test('awaitingInput status is observed while paused, then submit() resolves and the run succeeds', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('interactive');
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('before'), interactive]);

      final snapshots = <WorkflowProgress>[];
      runner.progress.addListener(() => snapshots.add(runner.progress.value));

      final future = runner.run(context);
      await Future.delayed(Duration.zero);

      expect(runner.statusOf('interactive'), equals(StepStatus.awaitingInput));
      expect(snapshots.any((s) => s.statusOf('before') == StepStatus.awaitingInput), isFalse);

      runner.submit('interactive', 'payload');
      final result = await future;

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:before', 'activate:interactive', 'submit:interactive:payload']));
    });

    test('fail(stepId, error) resolves the step as a failure and triggers LIFO rollback', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('interactive');
      final runner = WorkflowRunner<TestContext>(
        steps: [LogStep('before'), interactive],
      );

      final future = runner.run(context);
      await Future.delayed(Duration.zero);

      runner.fail('interactive', Exception('rejected'));
      final result = await future;

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).failedStepId, equals('interactive'));
      expect(context.logs, contains('fail:interactive'));
      expect(context.logs, contains('rollback:before'));
    });

    test('Cancelling while awaiting input yields WorkflowCancelled and invokes onDeactivateOrCancel exactly once', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('interactive');
      final token = CancellationToken();
      final runner = WorkflowRunner<TestContext>(steps: [interactive]);

      final future = runner.run(context, cancellationToken: token);
      await Future.delayed(Duration.zero);

      token.cancel();
      final result = await future;

      expect(result, isA<WorkflowCancelled<TestContext>>());
      expect(interactive.deactivated, isTrue);
      expect(context.logs.where((l) => l == 'deactivate:interactive').length, equals(1));
    });

    test('onDeactivateOrCancel delegates through RetryStepDecorator/TimeoutStepDecorator/ConditionalStep', () async {
      final context = TestContext();
      final interactive = InteractiveTestStep('wrapped');
      final token = CancellationToken();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          ConditionalStep(
            id: 'cond',
            condition: (_) => true,
            step: RetryStepDecorator(
              step: TimeoutStepDecorator(step: interactive, timeout: const Duration(seconds: 5)),
              initialDelay: Duration.zero,
            ),
          ),
        ],
      );

      final future = runner.run(context, cancellationToken: token);
      await Future.delayed(Duration.zero);

      token.cancel();
      await future;

      expect(interactive.deactivated, isTrue);
    });

    test('onDeactivateOrCancel delegates through ParallelStep to every sub-step', () async {
      final context = TestContext();
      final first = InteractiveTestStep('first');
      final second = InteractiveTestStep('second');
      final token = CancellationToken();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          ParallelStep(id: 'parallel', subSteps: [first, second]),
        ],
      );

      final future = runner.run(context, cancellationToken: token);
      await Future.delayed(Duration.zero);

      token.cancel();
      await future;

      expect(first.deactivated, isTrue);
      expect(second.deactivated, isTrue);
    });

    test('Cancelling while a WorkflowStepGroup\'s inner InteractiveStep is active fires both hooks', () async {
      final context = TestContext();
      final inner = InteractiveTestStep('inner');
      final token = CancellationToken();
      final group = WorkflowStepGroup<TestContext>(id: 'group', steps: [inner]);
      final runner = WorkflowRunner<TestContext>(steps: [group]);

      final future = runner.run(context, cancellationToken: token);
      await Future.delayed(Duration.zero);

      token.cancel();
      await future;

      expect(inner.deactivated, isTrue);
    });
  });

  group('ActionWorkflowStep / WorkflowStep.action Tests', () {
    test('Basic success and rollback via the factory form', () async {
      final context = TestContext();
      final step = WorkflowStep<TestContext>.action(
        id: 'action_step',
        execute: (ctx, token) async {
          ctx.logs.add('execute:action_step');
          return const StepSuccess();
        },
        rollback: (ctx) async => ctx.logs.add('rollback:action_step'),
      );
      final runner = WorkflowRunner<TestContext>(steps: [step, FailingStep()]);

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(context.logs, equals(['execute:action_step', 'execute:failing', 'rollback:action_step']));
    });

    test('Composes with RetryStepDecorator', () async {
      final context = TestContext()..shouldFailStep = true;
      final actionRetryable = WorkflowStep<TestContext>.action(
        id: 'retryable_action',
        execute: (ctx, token) async {
          ctx.retryAttemptsCount++;
          if (ctx.shouldFailStep) return StepFailure(Exception('fail'));
          return const StepSuccess();
        },
      );
      final runner = WorkflowRunner<TestContext>(
        steps: [RetryStepDecorator(step: actionRetryable, maxAttempts: 3, initialDelay: Duration.zero)],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(context.retryAttemptsCount, equals(3));
    });

    test('Composes with TimeoutStepDecorator', () async {
      final context = TestContext();
      final never = WorkflowStep<TestContext>.action(
        id: 'never',
        execute: (ctx, token) => Completer<StepResult>().future,
      );
      final runner = WorkflowRunner<TestContext>(
        steps: [TimeoutStepDecorator(step: never, timeout: const Duration(milliseconds: 20))],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).error, isA<TimeoutException>());
    });

    test('Composes with ConditionalStep', () async {
      final context = TestContext()..hasFeatureX = false;
      final actionStep = WorkflowStep<TestContext>.action(
        id: 'conditional_action',
        execute: (ctx, token) async {
          ctx.logs.add('execute:conditional_action');
          return const StepSuccess();
        },
      );
      final runner = WorkflowRunner<TestContext>(
        steps: [ConditionalStep(id: 'cond', condition: (ctx) => ctx.hasFeatureX, step: actionStep)],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, isEmpty);
    });

    test('Composes inside WorkflowStepGroup', () async {
      final context = TestContext();
      final actionStep = WorkflowStep<TestContext>.action(
        id: 'grouped_action',
        execute: (ctx, token) async {
          ctx.logs.add('execute:grouped_action');
          return const StepSuccess();
        },
      );
      final runner = WorkflowRunner<TestContext>(
        steps: [WorkflowStepGroup(id: 'group', steps: [actionStep])],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:grouped_action']));
    });
  });

  group('ManagedWorkflowRunner Tests', () {
    group('ignore', () {
      test('swallows a call while one is in flight, handing back the in-flight Future', () async {
        var createCount = 0;
        final managed = ManagedWorkflowRunner<TestContext>(
          createRunner: () {
            createCount++;
            return WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]);
          },
          strategy: const ConcurrencyStrategy.ignore(),
        );

        final first = managed.run(TestContext());
        await Future.delayed(Duration.zero);
        final second = managed.run(TestContext());

        expect(identical(first, second), isTrue);
        expect(createCount, equals(1));

        managed.cancel();
        expect(await first, isA<WorkflowCancelled<TestContext>>());
      });

      test('starts fresh after the previous run has settled', () async {
        var createCount = 0;
        final managed = ManagedWorkflowRunner<TestContext>(
          createRunner: () {
            createCount++;
            return WorkflowRunner<TestContext>(steps: [LogStep('a')]);
          },
          strategy: const ConcurrencyStrategy.ignore(),
        );

        await managed.run(TestContext());
        await managed.run(TestContext());

        expect(createCount, equals(2));
      });
    });

    group('cancelExisting', () {
      test('waits for the old run (incl. rollback) to fully settle before the new run starts', () async {
        // run #1 blocks on WaitForCancelStep (needs the second `run()` call
        // to cancel it externally); run #2+ completes on its own, so the
        // test can simply await both futures instead of guessing at
        // microtask timing to synchronize with a still-blocking run.
        var createCount = 0;
        final sharedLog = <String>[];

        WorkflowRunner<TestContext> buildRunner() {
          createCount++;
          final myRunIndex = createCount;
          final rollbackStep = WorkflowStep<TestContext>.action(
            id: 'a',
            execute: (ctx, token) async {
              sharedLog.add('execute:a#$myRunIndex');
              return const StepSuccess();
            },
            rollback: (ctx) async {
              sharedLog.add('rollback-start:a#$myRunIndex');
              await Future.delayed(const Duration(milliseconds: 20));
              sharedLog.add('rollback-end:a#$myRunIndex');
            },
          );
          if (myRunIndex == 1) {
            return WorkflowRunner<TestContext>(steps: [rollbackStep, WaitForCancelStep('watch')]);
          }
          return WorkflowRunner<TestContext>(steps: [rollbackStep]);
        }

        final managed = ManagedWorkflowRunner<TestContext>(createRunner: buildRunner, strategy: const ConcurrencyStrategy.cancelExisting());

        final firstFuture = managed.run(TestContext());
        await Future.delayed(Duration.zero); // let run #1's 'a' succeed and 'watch' start blocking

        // Cancels run #1, awaits its full settlement (incl. the delayed rollback of 'a') before starting run #2.
        final secondFuture = managed.run(TestContext());
        final firstResult = await firstFuture;
        final secondResult = await secondFuture;

        expect(firstResult, isA<WorkflowCancelled<TestContext>>());
        expect(secondResult, isA<WorkflowSuccess<TestContext>>());
        expect(createCount, equals(2));

        // Every entry from run #1 (incl. its rollback) appears strictly
        // before run #2's own 'execute:a#2' — the direct proof there's no
        // corrupted-shared-state window between the old run settling and
        // the new one starting.
        expect(sharedLog, equals(['execute:a#1', 'rollback-start:a#1', 'rollback-end:a#1', 'execute:a#2']));
      });

      test('cancel() on idle is a no-op', () {
        final managed = ManagedWorkflowRunner<TestContext>(
          createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
          strategy: const ConcurrencyStrategy.cancelExisting(),
        );
        expect(managed.cancel, returnsNormally);
        expect(managed.isRunning, isFalse);
      });
    });

    group('enqueue', () {
      test('runs rapid calls strictly FIFO, each resolving with its own context\'s result', () async {
        final order = <int>[];
        final managed = ManagedWorkflowRunner<TestContext>(
          createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
          strategy: const ConcurrencyStrategy.enqueue(),
        );

        final contexts = [TestContext(), TestContext(), TestContext()];
        await Future.wait([
          managed.run(contexts[0]).then((_) => order.add(0)),
          managed.run(contexts[1]).then((_) => order.add(1)),
          managed.run(contexts[2]).then((_) => order.add(2)),
        ]);

        expect(order, equals([0, 1, 2]));
        for (final c in contexts) {
          expect(c.logs, equals(['execute:a']));
        }
      });

      test('exceeding maxQueueLength fails only the excess call without disturbing the queue', () async {
        final managed = ManagedWorkflowRunner<TestContext>(
          createRunner: () => WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
          strategy: const ConcurrencyStrategy.enqueue(maxQueueLength: 1),
        );

        final first = managed.run(TestContext()); // starts immediately
        final second = managed.run(TestContext()); // fills the 1-slot queue
        final third = managed.run(TestContext()); // queue already full -> rejected

        await expectLater(third, throwsStateError);

        managed.cancel(); // unblocks 'first' and drops 'second' from the queue
        expect(await first, isA<WorkflowCancelled<TestContext>>());
        expect(await second, isA<WorkflowCancelled<TestContext>>());
      });
    });
  });

  group('ParallelWorkflowRunner Tests', () {
    test('two concurrent handles have distinct runner instances and mutually untouched contexts', () async {
      final parallel = ParallelWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
      );

      final context1 = TestContext();
      final context2 = TestContext();
      final handle1 = parallel.run(context1);
      final handle2 = parallel.run(context2);

      expect(identical(handle1.runner, handle2.runner), isFalse);
      expect(identical(handle1.context, handle2.context), isFalse);

      await Future.wait([handle1.result, handle2.result]);
      expect(context1.logs, equals(['execute:a']));
      expect(context2.logs, equals(['execute:a']));
    });

    test('activeRuns drops each handle independently as it settles', () async {
      final parallel = ParallelWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
      );

      final handle1 = parallel.run(TestContext());
      expect(parallel.activeRuns, contains(handle1));
      await handle1.result;
      expect(parallel.activeRuns, isNot(contains(handle1)));
    });

    test('cancelling one handle does not affect another', () async {
      final parallel = ParallelWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
      );

      final context1 = TestContext();
      final context2 = TestContext();
      final handle1 = parallel.run(context1);
      final handle2 = parallel.run(context2);
      await Future.delayed(Duration.zero);

      handle1.cancel();
      expect(await handle1.result, isA<WorkflowCancelled<TestContext>>());
      expect(context2.logs, equals(['execute:watch'])); // handle2 unaffected, still blocking

      handle2.cancel();
      await handle2.result;
    });
  });

  group('SharedWorkflowRunner Tests', () {
    test('waitAll: isSessionActive stays true after result resolves until every joiner leaves', () async {
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
        rule: JoinCompletionRule.waitAll,
      );

      final h1 = shared.join(TestContext());
      final h2 = shared.join(TestContext());
      expect(shared.isSessionActive.value, isTrue);
      expect(identical(h1.result, h2.result), isTrue);

      await h1.result;
      expect(shared.isSessionActive.value, isTrue); // still active — nobody has left yet

      h1.leave();
      expect(shared.isSessionActive.value, isTrue); // one still attached

      h2.leave();
      expect(shared.isSessionActive.value, isFalse); // refcount reached zero
    });

    test('waitAll: a joiner who never leaves keeps the session open forever (documented behavior)', () async {
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [LogStep('a')]),
        rule: JoinCompletionRule.waitAll,
      );

      final h1 = shared.join(TestContext());
      await h1.result; // h1 never calls leave()

      expect(shared.isSessionActive.value, isTrue);
    });

    test('overrideByLatest: a non-latest joiner leaving is a no-op; the latest leaving closes and cancels the run', () async {
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
        rule: JoinCompletionRule.overrideByLatest,
      );

      final h1 = shared.join(TestContext()); // earlier joiner
      final h2 = shared.join(TestContext()); // latest joiner

      h1.leave(); // non-latest -> no-op
      expect(shared.isSessionActive.value, isTrue);

      h2.leave(); // latest -> closes immediately, cancels the still-in-flight run
      expect(shared.isSessionActive.value, isFalse);

      // Same shared Future for both — resolves cancelled even for h1, who never triggered the close.
      expect(await h1.result, isA<WorkflowCancelled<TestContext>>());
    });

    test('overrideByLatest: the latest joiner leaving first closes immediately regardless of an earlier joiner still attached', () async {
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
        rule: JoinCompletionRule.overrideByLatest,
      );

      final h1 = shared.join(TestContext());
      final h2 = shared.join(TestContext());

      h2.leave(); // latest leaves first -> closes immediately
      expect(shared.isSessionActive.value, isFalse);
      expect(await h1.result, isA<WorkflowCancelled<TestContext>>());

      expect(h1.leave, returnsNormally); // no-op, session already closed
    });

    test('firstWins: the first leave() from any joiner closes immediately; later leaves are no-ops', () async {
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () => WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
        rule: JoinCompletionRule.firstWins,
      );

      final h1 = shared.join(TestContext());
      final h2 = shared.join(TestContext());

      h1.leave(); // earlier joiner, but first to leave -> closes immediately
      expect(shared.isSessionActive.value, isFalse);
      expect(await h2.result, isA<WorkflowCancelled<TestContext>>());

      expect(h2.leave, returnsNormally); // no-op
    });

    test('a second join() while a session is active never calls createRunner again; both share the identical result', () async {
      var createCount = 0;
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () {
          createCount++;
          return WorkflowRunner<TestContext>(steps: [LogStep('a')]);
        },
        rule: JoinCompletionRule.waitAll,
      );

      final h1 = shared.join(TestContext());
      final h2 = shared.join(TestContext());
      expect(createCount, equals(1));
      expect(identical(h1.result, h2.result), isTrue);

      await h1.result;
      h1.leave();
      h2.leave();
    });

    test('a join() after a session has fully closed starts a genuinely new session', () async {
      var createCount = 0;
      final shared = SharedWorkflowRunner<TestContext>(
        createRunner: () {
          createCount++;
          return WorkflowRunner<TestContext>(steps: [LogStep('a')]);
        },
        rule: JoinCompletionRule.firstWins,
      );

      final h1 = shared.join(TestContext());
      await h1.result;
      h1.leave();
      expect(createCount, equals(1));

      final h2 = shared.join(TestContext());
      expect(createCount, equals(2));
      await h2.result;
      h2.leave();
    });
  });

  group('FlowContext write interception Tests', () {
    test('Bare FlowContext: writerStepId is null with no active step, and the active step id once set', () {
      final calls = <(String, Object?, String?)>[];
      final context = TestContext();
      context.setWriteInterceptor((key, value, writerStepId) => calls.add((key, value, writerStepId)));

      context.write('k1', 'v1');
      context.setActiveStepId('s1');
      context.write('k2', 'v2');

      expect(calls, equals([('k1', 'v1', null), ('k2', 'v2', 's1')]));
    });

    test('Integration: listener records each step\'s own writes in order', () async {
      final listener = RecordingListener();
      final context = TestContext();
      final writerA = WorkflowStep<TestContext>.action(
        id: 'a',
        execute: (ctx, token) async {
          ctx.write('fromA', 1);
          return const StepSuccess();
        },
      );
      final writerB = WorkflowStep<TestContext>.action(
        id: 'b',
        execute: (ctx, token) async {
          ctx.write('fromB', 2);
          return const StepSuccess();
        },
      );
      final runner = WorkflowRunner<TestContext>(steps: [writerA, writerB], listener: listener);

      await runner.run(context);

      expect(listener.writes, equals([('fromA', 1, 'a'), ('fromB', 2, 'b')]));
    });

    test('A write after run() completes does not fire the (detached) listener, but still succeeds', () async {
      final listener = RecordingListener();
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(steps: [LogStep('a')], listener: listener);

      await runner.run(context);
      listener.writes.clear();
      context.write('afterRun', 5);

      expect(listener.writes, isEmpty);
      expect(context.read<int>('afterRun'), equals(5));
    });

    test('A rejected scoped-immutability overwrite does not fire onContextWrite', () async {
      final listener = RecordingListener();
      final context = TestContext();
      final conflictingStep = WorkflowStep<TestContext>.action(
        id: 'conflict',
        execute: (ctx, token) async {
          ctx.write('shared', 'blocked');
          return const StepSuccess();
        },
      );
      // Simulate 'shared' already owned by a different step, before this run starts.
      context.setActiveStepId('other');
      context.write('shared', 'original');
      context.setActiveStepId(null);

      final runner = WorkflowRunner<TestContext>(steps: [conflictingStep], listener: listener);
      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(listener.writes, isEmpty);
    });
  });
}
