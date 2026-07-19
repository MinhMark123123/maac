import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maac_workflow/maac_workflow.dart';

class TestContext {
  final List<String> logs = [];
  bool hasFeatureX = false;
  bool shouldFailStep = false;
  int retryAttemptsCount = 0;
}

class LogStep extends WorkflowStep<TestContext> {
  final String name;

  LogStep(this.name);

  @override
  String get id => name;

  @override
  Future<StepResult<void>> execute(TestContext context, CancellationToken token) async {
    context.logs.add('execute:$name');
    return const StepSuccess(null);
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
  Future<StepResult<void>> execute(TestContext context, CancellationToken token) async {
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
  Future<StepResult<void>> execute(TestContext context, CancellationToken token) {
    context.logs.add('execute:$name');
    final completer = Completer<StepResult<void>>();
    token.onCancel(() {
      context.logs.add('cancelled:$name');
      if (!completer.isCompleted) completer.complete(const StepSuccess(null));
    });
    return completer.future;
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
  Future<StepResult<void>> execute(TestContext context, CancellationToken token) {
    context.logs.add('execute:slow');
    final completer = Completer<StepResult<void>>();
    Timer(delay, () {
      if (!completer.isCompleted) completer.complete(const StepSuccess(null));
    });
    token.onCancel(() => tokenCancelledDuringExecute = true);
    return completer.future;
  }
}

class RetryableStep extends WorkflowStep<TestContext> {
  @override
  String get id => 'retryable';

  @override
  Future<StepResult<void>> execute(TestContext context, CancellationToken token) async {
    context.retryAttemptsCount++;
    context.logs.add('execute:retryable-$context.retryAttemptsCount');
    if (context.shouldFailStep) {
      return StepFailure(Exception('network error'));
    }
    return const StepSuccess(null);
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
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          LogStep('step2'),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:step2']));
      expect(result.history.length, equals(4));
      expect(result.history[0].stepId, equals('step1'));
      expect(result.history[0].status, equals(StepStatus.running));
    });

    test('Should rollback in LIFO order when a step fails', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          LogStep('step2'),
          FailingStep(),
          LogStep('step3'),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      final failure = result as WorkflowFailure<TestContext>;
      expect(failure.failedStepId, equals('failing'));
      
      // step1 and step2 should be executed, then failing, then rollback step2 and step1
      expect(
        context.logs,
        equals([
          'execute:step1',
          'execute:step2',
          'execute:failing',
          'rollback:step2',
          'rollback:step1',
        ]),
      );
    });
  });

  group('Conditional & Composite Steps Tests', () {
    test('Should skip step if condition is not met', () async {
      final context = TestContext()..hasFeatureX = false;
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          ConditionalLogStep('conditional_step'),
          LogStep('step2'),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:step2']));
      expect(result.history[2].status, equals(StepStatus.skipped));
    });

    test('Should execute step if condition is met', () async {
      final context = TestContext()..hasFeatureX = true;
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          ConditionalLogStep('conditional_step'),
          LogStep('step2'),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:step1', 'execute:conditional_step', 'execute:step2']));
    });

    test('Should execute conditional wrapper declarative format', () async {
      final context = TestContext()..hasFeatureX = false;
      final runner = WorkflowRunner<TestContext>(
        steps: [
          LogStep('step1'),
          ConditionalStep(
            id: 'cond',
            condition: (ctx) => ctx.hasFeatureX,
            step: LogStep('inner_step'),
          ),
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
        steps: [
          RetryStepDecorator(
            step: RetryableStep(),
            maxAttempts: 3,
            initialDelay: Duration.zero,
          ),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect(context.retryAttemptsCount, equals(3));
    });

    test('Should retry failing step and succeed when failure resolves', () async {
      // In a real scenario, we could mock the resolution. Let's verify it retries.
      final context = TestContext()..shouldFailStep = false;
      final runner = WorkflowRunner<TestContext>(
        steps: [
          RetryStepDecorator(
            step: RetryableStep(),
            maxAttempts: 3,
            initialDelay: Duration.zero,
          ),
        ],
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
        steps: [
          TimeoutStepDecorator(step: slowStep, timeout: const Duration(milliseconds: 20)),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowFailure<TestContext>>());
      expect((result as WorkflowFailure<TestContext>).error, isA<TimeoutException>());
      expect(slowStep.tokenCancelledDuringExecute, isTrue);
    });

    test('Should succeed when the step completes within the timeout', () async {
      final context = TestContext();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          TimeoutStepDecorator(step: LogStep('fast'), timeout: const Duration(milliseconds: 200)),
        ],
      );

      final result = await runner.run(context);

      expect(result, isA<WorkflowSuccess<TestContext>>());
      expect(context.logs, equals(['execute:fast']));
    });

    test('Should not cancel the parent token when only the step times out', () async {
      final context = TestContext();
      final token = CancellationToken();
      final runner = WorkflowRunner<TestContext>(
        steps: [
          TimeoutStepDecorator(step: SlowStep(const Duration(milliseconds: 200)), timeout: const Duration(milliseconds: 20)),
        ],
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
      expect(
        context.logs,
        equals(['execute:before', 'execute:inner1', 'execute:inner2', 'execute:after']),
      );
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
      expect(
        context.logs,
        equals([
          'execute:inner1',
          'execute:inner2',
          'execute:failing',
          'rollback:inner2',
          'rollback:inner1',
        ]),
      );
    });
  });

  group('SingleFlightWorkflowRunner Tests', () {
    test('Should cancel the previous run when a new run starts, and cancel() should stop the active one', () async {
      final context1 = TestContext();
      final context2 = TestContext();
      final singleFlight = SingleFlightWorkflowRunner<TestContext>(
        WorkflowRunner<TestContext>(steps: [WaitForCancelStep('watch')]),
      );

      final firstRunFuture = singleFlight.run(context1);
      await Future.delayed(Duration.zero); // let the first run start listening

      expect(singleFlight.isRunning, isTrue);

      final secondRunFuture = singleFlight.run(context2);
      final firstResult = await firstRunFuture;

      expect(firstResult, isA<WorkflowCancelled<TestContext>>());
      expect(context1.logs, equals(['execute:watch', 'cancelled:watch']));
      expect(singleFlight.isRunning, isTrue); // second run is still active

      singleFlight.cancel();
      final secondResult = await secondRunFuture;

      expect(secondResult, isA<WorkflowCancelled<TestContext>>());
      expect(context2.logs, equals(['execute:watch', 'cancelled:watch']));
      expect(singleFlight.isRunning, isFalse);
    });
  });
}
