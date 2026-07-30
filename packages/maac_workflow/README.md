# maac_workflow

[![pub package](https://img.shields.io/pub/v/maac_workflow.svg)](https://pub.dev/packages/maac_workflow)

A highly resilient, stateful, and declarative asynchronous workflow and step pipeline orchestration engine for Dart & Flutter.

---

## 🌟 Overview

In modern Flutter applications, business processes such as **multi-step signup flows, complex checkout processes, or sequential API setups** are often written directly inside ViewModels or UI widgets. This inevitably leads to:
* **Callback Hell / Async Sprawl**: Hard to maintain, reason about, or debug.
* **Complex Rollback / Compensation**: Extemely tedious to clean up intermediate states if a later step fails.
* **Brittle Retry Policies**: Manual retry logic cluttering business rules.
* **Poor Analytics & Logging**: Impossible to track process status in a unified manner.

`maac_workflow` introduces a clean, domain-driven **Step Pipeline Architecture** to solve these issues. It isolates sequential, stateful operations into independent, reusable, and compensable **Steps**, coordinated by a powerful **Workflow Engine**.

---

## 🚀 Key Features

**Core**
* **🔒 Scoped Immutability**: `FlowContext`, the required base for every workflow's shared state, is a key-value store that makes data written by one step strictly read-only to every step that runs after it — enforced by the engine, not by convention.
* **🔄 Transactional Rollbacks (Compensation)**: Automatically triggers rollback operations in reverse order (LIFO) for previously succeeded steps if a later step fails.
* **🛡️ Type-Safe sealed Outcomes**: Uses Dart 3 sealed classes (`WorkflowSuccess`, `WorkflowFailure`, `WorkflowCancelled`) to enforce compile-time exhaustive checking in UI/ViewModel.
* **🛑 Integrated Cancellation**: Simple cancellation tokens to abort workflows mid-flight when a user navigates away or manually cancels. `WorkflowStep.onDeactivateOrCancel` gives the actively-running step an immediate cleanup hook.
* **📊 Auditing & Telemetry**: `WorkflowListener` lifecycle hooks — including every `FlowContext` write — to seamlessly bind global loading indicators, telemetry, or debug logging.

**Step Definitions**
* **🪶 Flexible Step Definition**: Define a step by passing its handler functions straight into `WorkflowStep.action(...)` — no subclass required for simple steps.
* **🔂 Sustained Steps**: `WorkflowStep.sustained(...)` models work with no natural completion of its own — a live stream subscription, an open connection, a polling loop — that runs until the step is cancelled or deactivated, without hand-rolling a `Completer`/`CancellationToken` dance per step.
* **⏸️ Interactive Steps**: `InteractiveStep` pauses a workflow to wait for an external signal — typically UI input — without any step author hand-rolling a `Completer`. Resume it from outside via `WorkflowRunner.submit`/`.fail`.

**Composites & Decorators** — all interoperable, since each is itself a `WorkflowStep`
* `ConditionalStep` to branch flows cleanly using dynamic predicates.
* `WorkflowStepGroup` to embed a whole sub-pipeline as a single step, so large flows compose out of smaller, named, independently testable ones.
* `ParallelStepGroup` to run independent asynchronous steps concurrently as a single step — the concurrent counterpart to `WorkflowStepGroup`, with an optional `listener` to observe each sub-step's own lifecycle individually.
* `RetryStepDecorator` to automatically retry brittle steps with custom delay policies (e.g., Exponential Backoff).
* `TimeoutStepDecorator` to fail a step that runs longer than expected, without cancelling the whole workflow.

**Progress**
* **📍 Live Step Progress**: `WorkflowRunner.progress` exposes a `ValueListenable<WorkflowProgress>` with the currently executing step id and the last known status of every step — drive a stepper/progress bar UI without hand-rolling counters in `WorkflowListener`.

**Concurrency**
* **🔀 Concurrency Strategies**: `ManagedWorkflowRunner` governs what happens when a workflow is triggered again while already running — `ignore`, `cancelExisting`, or `enqueue` — plus `ParallelWorkflowRunner` for fully independent concurrent runs and `SharedWorkflowRunner` for merging multiple callers into one shared session.

---

## 📦 Installation

Add `maac_workflow` to your `pubspec.yaml`:

```yaml
dependencies:
  maac_workflow:
    path: packages/maac_workflow # For local melos workspaces
```

---

## 🛠️ Quick Start

### 1. Define your Workflow Context
Every `WorkflowRunner<TContext>` requires `TContext` to extend `FlowContext` — the
base every workflow's shared state builds on (see "`FlowContext` — Scoped Immutability"
further down for what it buys you). The simplest way to use it is exactly like a regular
mutable data class, just extending `FlowContext` instead of nothing:

```dart
class SignupContext extends FlowContext {
  final String email;
  final String password;
  final String? avatarPath;
  final String? referralCode;

  String? userId;
  String? uploadedAvatarUrl;

  SignupContext({
    required this.email,
    required this.password,
    this.avatarPath,
    this.referralCode,
  });

  bool get hasAvatar => avatarPath != null;
  bool get hasReferralCode => referralCode != null && referralCode!.isNotEmpty;
}
```

### 2. Implement Your Steps
Inherit from `WorkflowStep<T>` to implement individual operations. Optionally implement `rollback` to support compensation if subsequent steps fail.

```dart
class CreateAccountStep extends WorkflowStep<SignupContext> {
  @override
  String get id => 'create_account';

  @override
  Future<StepResult> execute(SignupContext context, CancellationToken token) async {
    try {
      // Simulate API call to create the account
      final userId = await authApi.createAccount(context.email, context.password);
      context.userId = userId;
      return const StepSuccess();
    } catch (e, stack) {
      return StepFailure(e, stack);
    }
  }

  @override
  Future<void> rollback(SignupContext context) async {
    // If the account was created, but a later step fails, delete it so the user
    // can retry signup with the same email instead of hitting a "duplicate email" error.
    if (context.userId != null) {
      await authApi.deleteAccount(context.userId!);
      context.userId = null;
    }
  }
}
```

For simple steps, skip the class entirely and use `WorkflowStep.action(...)` — see
"`WorkflowStep.action` — Functional Steps" further down.

### 3. Orchestrate and Run the Workflow
Run your pipeline declaratively. Wrap brittle steps with retry decorators, and conditionally execute steps.

```dart
final signupWorkflow = WorkflowRunner<SignupContext>(
  steps: [
    // Automatically retry account creation up to 3 times with exponential backoff on network issues
    RetryStepDecorator(
      step: CreateAccountStep(),
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 1),
    ),
    // Branching: only execute avatar upload if the user picked one
    ConditionalStep(
      id: 'conditional_upload_avatar',
      condition: (ctx) => ctx.hasAvatar,
      step: UploadAvatarStep(),
    ),
    ConditionalStep(
      id: 'conditional_apply_referral',
      condition: (ctx) => ctx.hasReferralCode,
      step: ApplyReferralCodeStep(),
    ),
    SendWelcomeEmailStep(),
  ],
);

// Execute the workflow
final result = await signupWorkflow.run(
  SignupContext(email: 'jane@doe.com', password: 's3cret'),
);

// Safely pattern match results using Dart 3 sealed class capabilities
switch (result) {
  case WorkflowSuccess():
    print('Signup Completed Successfully!');
  case WorkflowFailure(:final failedStepId, :final error):
    print('Failed at step [$failedStepId] with error: $error');
  case WorkflowCancelled():
    print('Signup was cancelled.');
}
```

---


## 🧱 Core

### `FlowContext` — Scoped Immutability

Every `TContext` extends `FlowContext`, which — beyond being a normal mutable
Dart object, as shown above — is also a key-value store that can enforce a
stronger rule: once a step has written a key, every step that runs *after* it
gets read-only access. This models what "shared context across a pipeline"
should mean in a strict pipeline — later steps see history, they don't rewrite it.

```dart
class SignupContext extends FlowContext {}

// Inside a step's execute()/onSubmit():
context.write('userId', newUserId);       // first writer claims the key
context.read<String>('userId');           // any step can always read it

// A later step trying to overwrite it:
context.write('userId', otherId);          // throws StateError
```

A step overwriting its *own* key is always allowed — this is what lets a
step's own `rollback()` reset the same key it wrote during `execute()`. Writes
made with no step active (before a run starts, or between runs — e.g. seeding
input from whatever code configures the run) are always unrestricted and
reset that key's ownership, since this rule is about steps not stepping on
each other, not about the code that configures a run:

```dart
class SignupController {
  final _context = SignupContext();

  void startFlow() {
    _context.write('forceFailure', false); // fine — no step is active yet
    _signupWorkflow.run(_context);
  }
}
```

You don't have to use the store at all — plain mutable fields (as in the
Quick Start example above) work exactly as before and simply don't
participate in this tracking. Reach for the store when you specifically want
the engine to enforce read-only history for a piece of shared state.

### `WorkflowStep` & `WorkflowRunner` — Sequential Run & Rollback

The core contract, already exercised end to end in "Quick Start" above: a
`WorkflowRunner<TContext>` runs `steps` in order, and if one fails, every step
that already succeeded is `rollback`ed automatically, in reverse (LIFO) order:

```dart
final result = await WorkflowRunner<SignupContext>(steps: [stepA, stepB]).run(context);
switch (result) {
  case WorkflowSuccess(): ...
  case WorkflowFailure(:final failedStepId, :final error): ...
  case WorkflowCancelled(): ...
}
```

`WorkflowRunner` is reused across multiple `run()` calls in the usual pattern (declared
once in a ViewModel) — call `WorkflowRunner.dispose()` from `onDispose()` to release the
underlying `ValueNotifier` backing `progress` (see "`WorkflowRunner.progress`" below).

### `CancellationToken` — Cancelling Mid-Flight

Every `run()` carries a `CancellationToken` — created automatically if you don't pass
one, or supplied yourself so you can cancel it from outside (e.g. a ViewModel's
`onDispose`). Cancellation is cooperative: a step checks it between units of work, it
can't interrupt a single `await` mid-flight.

```dart
final token = CancellationToken();
final resultFuture = signupWorkflow.run(context, cancellationToken: token);

// Later, e.g. from onDispose():
token.cancel();
```

Inside a step:

```dart
execute: (context, token) async {
  for (final chunk in chunks) {
    await uploadChunk(chunk);
    token.throwIfCancelled(); // stops between chunks, not mid-upload
  }
  return const StepSuccess();
}
```

A cancelled run resolves as `WorkflowCancelled`, not `WorkflowFailure`.
`WorkflowStep.onDeactivateOrCancel` gives the actively-running step an immediate cleanup
hook the instant `cancel()` fires, regardless of whether `execute()` has resolved yet —
`WorkflowStep.sustained` (see "Step Definitions" below) builds directly on this for steps
with no natural completion of their own.

### `WorkflowListener` — Observing a Run

Attach a `WorkflowListener<TContext>` to a `WorkflowRunner` to observe its lifecycle from
the outside — step start/success/failure, rollback, and every successful
`context.write(...)` — without any step needing to log anything itself:

```dart
class AnalyticsListener extends WorkflowListener<SignupContext> {
  @override
  void onWorkflowStart(SignupContext context) => analytics.track('signup_started');

  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, SignupContext context) =>
      analytics.track('signup_step_failed', {'step': stepId, 'error': '$error'});

  @override
  void onWorkflowSuccess(SignupContext context) => analytics.track('signup_completed');

  @override
  void onContextWrite(String key, Object? value, String? writerStepId, SignupContext context) =>
      analytics.track('flow_context_write', {'key': key, 'writerStepId': writerStepId});
}

final signupWorkflow = WorkflowRunner<SignupContext>(steps: [...], listener: AnalyticsListener());
```

Every hook has a no-op default, so a listener only overrides what it actually cares about:
`onWorkflowStart`/`onWorkflowSuccess`/`onWorkflowFailure`, `onStepStart`/`onStepSuccess`/
`onStepFailure`/`onStepSkip`, the rollback trio (`onStepRollbackStart`/`Success`/`Failure`),
and `onContextWrite` — fired after every successful `context.write(...)` made during the
run, with `writerStepId` the id of whichever step made it (or `null` for a write made with
no step active — see "`FlowContext` — Scoped Immutability" above). Doesn't fire for a write
rejected by scoped immutability (the `StateError` case) — only successful writes. Useful for
centralized logging, analytics, or a live debug/flow-visualizer screen, decoupled from the
steps' own business logic.

---

## 🪶 Step Definitions

### `WorkflowStep.action` — Functional Steps

Subclassing `WorkflowStep<T>` is still the right call for steps with their own
state or that get reused across flows, but for a step that's just a few lines,
`WorkflowStep.action(...)` skips the class entirely — it's fully interoperable
with every decorator/composite below, since it implements the exact same
`WorkflowStep` interface a subclass would:

```dart
final signupWorkflow = WorkflowRunner<SignupContext>(
  steps: [
    WorkflowStep<SignupContext>.action(
      id: 'create_account',
      execute: (context, token) async {
        context.userId = await authApi.createAccount(context.email, context.password);
        return const StepSuccess();
      },
      rollback: (context) async {
        if (context.userId != null) await authApi.deleteAccount(context.userId!);
      },
    ),
    SendWelcomeEmailStep(),
  ],
);
```

`execute` is required; `rollback`, `canRun`, and `onDeactivateOrCancel` are all
optional, mirroring the methods you'd otherwise override on a subclass.

### `WorkflowStep.sustained` — Work With No Natural Completion

A common screen-level pattern: only **one** active subscription should ever be alive at a
time. Start watching when the screen is shown, stop when it's paused or disposed, and if
the target changes (e.g. switching chat rooms), cancel the previous subscription *before*
starting the new one — never let two run concurrently.

Model the subscription itself as a `WorkflowStep.sustained` — a step whose work has no
natural completion of its own. Unlike a regular step, it doesn't resolve once `start`
returns; it keeps running until the step is cancelled or deactivated, at which point
`stop` tears it down. Neither `start` nor `stop` ever see a raw `CancellationToken` —
cancellation is exactly what ends the step, so there's nothing left to poll; `stop` *is*
the reaction to it. The only thing `start` can actively report is failure, via the `fail`
callback it's handed (e.g. a stream's `onError`) — there's no matching "succeed now",
since a step with no natural completion has no natural "succeeded now" moment:

```dart
class OrderTrackingContext extends FlowContext {
  final String orderId;
  final void Function(OrderStatus) onStatusChanged;
  StreamSubscription<OrderStatus>? subscription;
  OrderTrackingContext({required this.orderId, required this.onStatusChanged});
}

final watchOrderStatusStep = WorkflowStep<OrderTrackingContext>.sustained(
  id: 'watch_order_status',
  start: (context, fail) {
    context.subscription = orderRepository.watchStatus(context.orderId).listen(context.onStatusChanged, onError: fail);
  },
  stop: (context) => context.subscription?.cancel(),
);
```

See "`ManagedWorkflowRunner` + `ConcurrencyStrategy`" under Concurrency below for how to
pair this with `cancelExisting()` to get "cancel the old subscription, start the new one"
bookkeeping for free.

### `InteractiveStep` — Pausing for External Input

A step that needs to pause and wait for something outside the workflow — most
commonly, a user filling out a form on screen — doesn't need to hand-roll a
`Completer`. Subclass `InteractiveStep<TContext, TInput>` instead:

```dart
// TInput is Object? here since this step doesn't need a payload — `void`
// isn't well-formed as a generic type argument used in a parameter position.
class BasicInfoStep extends InteractiveStep<SignupContext, Object?> {
  final SignupViewModel viewModel;
  BasicInfoStep(this.viewModel);

  @override
  String get id => 'basic_info';

  @override
  void onActivate(SignupContext context, CancellationToken token) {
    // Called once, as this step becomes active — trigger navigation here.
    viewModel.navigateToBasicInfoScreen();
  }

  @override
  StepResult onSubmit(SignupContext context, Object? input, CancellationToken token) {
    // Called when WorkflowRunner.submit('basic_info') resolves this step.
    return const StepSuccess();
  }
}
```

The page's own ViewModel resumes the workflow from the outside once the user
submits the form:

```dart
void onFormSubmitted() {
  coordinator.context.email = emailController.text;
  coordinator.context.password = passwordController.text;
  coordinator.workflowRunner.submit('basic_info');
}
```

`WorkflowRunner.submit(stepId, [input])` routes to that step's `onSubmit`;
`WorkflowRunner.fail(stepId, error)` routes to `onFail` (a plain `StepFailure`
by default). Both throw `StateError` if `stepId` isn't the step the engine is
actually waiting on — including the case where it *is* the active step but
isn't an `InteractiveStep` — so a stray or duplicate call can never resolve
the wrong step, or the same step twice. While paused, `StepStatus.awaitingInput`
flows through `WorkflowRunner.progress` just like any other status (see
"`WorkflowRunner.progress`" below), so a step indicator can render "waiting on
you" differently from "running."

If the workflow is cancelled while a step is paused, the engine resolves it
immediately as a cancelled failure — no step author code is needed for this,
unlike a hand-rolled `Completer` where you'd have to remember to wire
`CancellationToken.onCancel` yourself.

---

## 🧩 Composites & Decorators

All of these are themselves a `WorkflowStep`, so they compose freely with each other and
with the plain steps from "Step Definitions" above.

### `ConditionalStep` — Branching

Wraps another step so it only runs if a predicate over the context is true — skipped, not
failed, otherwise:

```dart
ConditionalStep(
  id: 'conditional_upload_avatar',
  condition: (ctx) => ctx.hasAvatar,
  step: UploadAvatarStep(),
)
```

A skipped step reports `StepStatus.skipped` through `WorkflowRunner.progress` and never
runs its `rollback` — which must already be a safe no-op if the step never ran, the same
convention every composite in this package relies on.

### `WorkflowStepGroup` — Sub-Pipelines

`WorkflowRunner` isn't itself a `WorkflowStep`, so it can't be nested directly. Use
`WorkflowStepGroup` to embed a whole sub-pipeline as a single step in a parent
workflow — useful for splitting a large flow into smaller, named, independently
testable pieces.

```dart
final signupWorkflow = WorkflowRunner<SignupContext>(
  steps: [
    RetryStepDecorator(step: CreateAccountStep(), maxAttempts: 3),
    WorkflowStepGroup(
      id: 'profile_setup',
      steps: [
        ConditionalStep(
          id: 'conditional_upload_avatar',
          condition: (ctx) => ctx.hasAvatar,
          step: UploadAvatarStep(),
        ),
        ConditionalStep(
          id: 'conditional_apply_referral',
          condition: (ctx) => ctx.hasReferralCode,
          step: ApplyReferralCodeStep(),
        ),
      ],
    ),
    SendWelcomeEmailStep(),
  ],
);
```

If a step inside `profile_setup` fails, the group rolls back its own already-succeeded
inner steps first, then reports the failure up as if `profile_setup` itself were the
failed step. If `profile_setup` succeeds but `SendWelcomeEmailStep` fails afterwards,
the parent rolls the group back too — which rolls back every inner step it ran, in
reverse order, same LIFO contract as the top-level runner.

### `ParallelStepGroup` — Concurrent Sub-Steps

The concurrent counterpart to `WorkflowStepGroup`: runs `subSteps` concurrently as a
single step instead of sequentially through a nested runner. Succeeds only if every
sub-step succeeds or is skipped; fails with the first failure encountered (the others
are still awaited to completion, per `Future.wait`'s default behavior, before this step
resolves):

```dart
ParallelStepGroup(
  id: 'fetch_dashboard_data',
  subSteps: [FetchProfileStep(), FetchNotificationsStep()],
  listener: DashboardListener(), // optional — forwards each sub-step's own lifecycle events
)
```

The parent `WorkflowRunner` only ever tracks this group's own `id`, not each sub-step
individually — pass `listener` if a UI needs live status per sub-step (its
`onStepStart`/`onStepSuccess`/`onStepFailure`/`onStepSkip` fire with each sub-step's own
id as they happen).

Known limitation: unlike `WorkflowStepGroup`, sub-steps here execute against the *same*
`FlowContext` active-step slot rather than each getting its own turn — every write any
sub-step makes while the group executes is attributed to the group's own `id`, not the
individual sub-step that made it. Give concurrent sub-steps disjoint context keys.

### `RetryStepDecorator` — Auto-Retry with Backoff

Wraps a brittle step to retry it automatically, with a configurable exponential backoff:

```dart
RetryStepDecorator(
  step: CreateAccountStep(),
  maxAttempts: 3,
  initialDelay: const Duration(seconds: 1),
  backoffFactor: 2.0,           // each retry waits longer than the last
  retryIf: (error) => error is! ValidationException, // optional — skip retrying some errors
)
```

Retries on a `StepFailure` result or a thrown exception from `execute()`; gives up and
reports the last failure once `maxAttempts` is reached, or immediately if `retryIf`
returns `false` for that error. Delegates `rollback`/`onDeactivateOrCancel` straight to
the wrapped step.

### `TimeoutStepDecorator` — Bounding Duration

Wrap any step to fail it — with a regular `StepFailure`, not a workflow-wide
cancellation — if it runs longer than expected. This composes with
`RetryStepDecorator`: retry a handful of times, each attempt bounded by its own
timeout.

```dart
final signupWorkflow = WorkflowRunner<SignupContext>(
  steps: [
    RetryStepDecorator(
      step: TimeoutStepDecorator(
        step: CreateAccountStep(),
        timeout: const Duration(seconds: 5),
      ),
      maxAttempts: 3,
    ),
    SendWelcomeEmailStep(),
  ],
);
```

A step wrapped this way still sees cancellation from the parent workflow's token as
normal — but a timeout itself only fails that one step (letting it stop any
in-flight work, e.g. abort an HTTP call) without cancelling the rest of the
workflow.

---

## 📍 Progress

### `WorkflowRunner.progress` — Live Step Status

Every `WorkflowRunner` exposes a `progress` `ValueListenable<WorkflowProgress>`, updated
synchronously as the run proceeds — no extra wiring through `WorkflowListener` required.
`WorkflowProgress` holds the id of the step currently executing (`currentStepId`, `null`
before the run starts or after it finishes) and the last known `StepStatus` of every step
reached so far (`pending`, `running`, `awaitingInput` — an `InteractiveStep` paused for
external input, see above — `success`, `failed`, `skipped`, `rollbackRunning`,
`rollbackSuccess`, or `rollbackFailed`).

```dart
final signupWorkflow = WorkflowRunner<SignupContext>(steps: [...]);

// Feed it straight into a ValueListenableBuilder to render a step indicator:
ValueListenableBuilder<WorkflowProgress>(
  valueListenable: signupWorkflow.progress,
  builder: (context, progress, _) {
    return Row(
      children: [
        for (final step in signupWorkflow.steps)
          _StepDot(status: progress.statusOf(step.id) ?? StepStatus.pending),
      ],
    );
  },
);
```

`WorkflowRunner` is reused across multiple `run()` calls in the usual pattern (declared
once in a ViewModel), so `progress` resets to `pending` for every step at the start of
each new run — it always reflects the most recent run, never a stale one. Call
`WorkflowRunner.dispose()` from `onDispose()` to release the underlying `ValueNotifier`,
same as any other `ChangeNotifier`-based resource.

`ManagedWorkflowRunner`/`SharedWorkflowRunner` (below) build a fresh `WorkflowRunner` per
logical run instead of wrapping one fixed instance, so they don't expose a single
`progress` themselves — `ParallelRunHandle` (from `ParallelWorkflowRunner`) exposes its
own invocation's `runner.progress` directly, which is the only place a "current progress"
concept is actually well-defined once more than one logical run can exist.

---

## 🔀 Concurrency

For "what happens if `run()` is triggered again while already running" — three wrapper
classes cover five required behaviors between them.

### `ManagedWorkflowRunner` + `ConcurrencyStrategy`

Covers three of the five behaviors — `ignore`, `cancelExisting`, `enqueue` — all sharing
the same "exactly one logical run owns the runner at a time" shape. Pick one at
construction:

```dart
ManagedWorkflowRunner<TContext>({
  required WorkflowRunnerFactory<TContext> createRunner,
  required ConcurrencyStrategy strategy,
});
```

* **`ConcurrencyStrategy.ignore()`** — swallow the new call entirely; the in-flight run
  continues untouched, and the caller gets back that same run's `Future` (their own
  `context` argument is never used if a call gets swallowed).
* **`ConcurrencyStrategy.cancelExisting()`** — cancel the old run, wait for it to fully
  settle (rollback included), then start fresh. Pairs naturally with
  `WorkflowStep.sustained` (see "Step Definitions" above) for "only one active
  subscription at a time" screens:

  ```dart
  class OrderTrackingController {
    final _watchOrder = ManagedWorkflowRunner<OrderTrackingContext>(
      createRunner: () => WorkflowRunner(steps: [watchOrderStatusStep]),
      strategy: const ConcurrencyStrategy.cancelExisting(),
    );

    void watchOrder(String orderId) {
      // Cancels whatever subscription is currently active — waiting for it to
      // fully settle, rollback included — before starting this one.
      _watchOrder.run(OrderTrackingContext(orderId: orderId, onStatusChanged: _handleStatusChanged));
    }

    // Wire these to whatever lifecycle hooks your screen/controller already
    // has (e.g. a StatefulWidget's didChangeAppLifecycleState, or a
    // ViewModel's onResume/onPause if you're using maac_mvvm).
    void onScreenVisible() {
      watchOrder(currentOrderId); // (Re)start the subscription.
    }

    void onScreenHidden() {
      _watchOrder.cancel(); // Stop it. onScreenVisible() restarts it.
    }
  }
  ```

* **`ConcurrencyStrategy.enqueue({int? maxQueueLength})`** — queue the new call; it runs
  once every call ahead of it has finished (success, failure, or cancellation), strictly
  FIFO. Exceeding `maxQueueLength` rejects only the excess call — like every other
  outcome in this package, by resolving immediately with a `WorkflowFailure` carrying a
  `QueueFullException` (never a thrown exception) — without disturbing the existing queue.

All three share the same `run(context) -> Future<WorkflowResult<TContext>>` shape, so
switching strategies at a call site is just swapping the `strategy:` argument. It takes a
**factory**, not a fixed `WorkflowRunner` instance — a fresh runner (and fresh step
instances) is built for every logical run, since `WorkflowRunner`/`InteractiveStep` hold
per-instance mutable state that two overlapping runs can never safely share.

### `ParallelWorkflowRunner`

Covers `parallel` — no "one current run" concept. Every call spins up a fully independent
run — its own `WorkflowRunner`, its own isolated `FlowContext` — running concurrently
with any others rather than cancelling or queuing them:

```dart
final uploads = ParallelWorkflowRunner<UploadContext>(
  createRunner: () => WorkflowRunner(steps: [UploadFileStep()]),
);

final handle = uploads.run(UploadContext(file: picked));
// `run()` returns a handle synchronously — inspect this specific invocation's
// own progress without any cross-run aggregation:
ValueListenableBuilder<WorkflowProgress>(
  valueListenable: handle.progress,
  builder: (context, progress, _) => UploadProgressBar(progress),
);

await handle.result;               // this invocation's own outcome
uploads.activeRuns;                // every upload still in flight right now
```

### `SharedWorkflowRunner` + `JoinCompletionRule`

Covers `joinOrCreate`: if nothing is running, starts a new session; if one's already in
flight (e.g. a global loading indicator), merges the new call into it instead of starting
a second physical run — avoiding duplicate work and UI flicker:

```dart
final shared = SharedWorkflowRunner<SyncContext>(
  createRunner: () => WorkflowRunner(steps: [SyncStep()]),
  rule: JoinCompletionRule.waitAll,
);

final handle = shared.join(SyncContext());
// Bind a shared loading indicator to this — same instance across every joiner:
shared.isSessionActive;

await handle.result;   // the session's one physical run — identical Future for every joiner
handle.leave();         // call from teardown, e.g. onDispose
```

There's exactly one physical run per session — every joiner's `result` is the identical
`Future`, resolving at one instant for everyone. `JoinCompletionRule` doesn't change *when
the real work finishes*; it governs when `isSessionActive` closes once multiple joiners
are attached, **and whether closing early also cancels the still-in-flight run**:

* **`waitAll`** — reference-counted: the session stays active until every joiner that
  attached has called `leave()`. The only rule where the run is never cut short by a
  joiner leaving early. A joiner who never calls `leave()` leaves the session open
  forever — fully your responsibility to avoid, there's no automatic timeout.
* **`overrideByLatest`** — the most recently joined caller owns the session. When *that*
  joiner leaves, the session closes immediately **and cancels the run if still in
  flight**, regardless of whether earlier joiners are still attached — their `result`
  resolves as `WorkflowCancelled` at that point.
* **`firstWins`** — the very first `leave()` from *any* joiner closes the session
  immediately and cancels the run if still in flight; every other joiner's `leave()`
  becomes a no-op once that happens.

**If any joiner needs the real success/failure outcome rather than just a "something
happened" signal, use `waitAll`.** Under the other two rules, an early close can turn
every attached joiner's `result` into `WorkflowCancelled` regardless of how the work
would otherwise have turned out — appropriate for a pure UI signal (a shared spinner),
not for a result multiple callers actually depend on.

---

## 🗺️ Where to Go Next

- **Example app → Basics** (`packages/maac_workflow/example`) — one minimal, focused
  screen per concept documented above, deliberately bare of UI chrome so each one reads
  as "just the API".
- **Example app → Signup / Sequential API / Single-Flight flows** — fuller showcases
  combining several concepts into one realistic screen.

---

## 🧭 Documentation

For the wider MAAC ecosystem this package is part of — install guides, architecture
philosophy, and specs for the other MAAC packages — see the centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- 🔀 [**`maac_workflow` Spec**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_workflow.md)
- 🏗️ [**Architecture Philosophy**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#architecture-philosophy)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.
