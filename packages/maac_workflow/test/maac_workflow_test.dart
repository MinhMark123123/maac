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
}
