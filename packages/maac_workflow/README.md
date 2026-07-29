# maac_workflow

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

* **📦 Highly Reusable Steps**: Define single-responsibility steps with explicit execution logic.
* **🔄 Transactional Rollbacks (Compensation)**: Automatically triggers rollback operations in reverse order (LIFO) for previously succeeded steps if a later step fails.
* **🛡️ Type-Safe sealed Outcomes**: Uses Dart 3 sealed classes (`WorkflowSuccess`, `WorkflowFailure`, `WorkflowCancelled`) to enforce compile-time exhaustive checking in UI/ViewModel.
* **⚡ Declarative Orchestration**:
  * `ConditionalStep` to branch flows cleanly using dynamic predicates.
  * `ParallelStepGroup` to run independent asynchronous steps concurrently as a single step — the concurrent counterpart to `WorkflowStepGroup`, with an optional `listener` to observe each sub-step's own lifecycle individually.
  * `RetryStepDecorator` to automatically retry brittle steps with custom delay policies (e.g., Exponential Backoff).
  * `TimeoutStepDecorator` to fail a step that runs longer than expected, without cancelling the whole workflow.
  * `WorkflowStepGroup` to embed a whole sub-pipeline as a single step, so large flows compose out of smaller, named, independently testable ones.
* **⏸️ Interactive Steps**: `InteractiveStep` pauses a workflow to wait for an external signal — typically UI input — without any step author hand-rolling a `Completer`. Resume it from outside via `WorkflowRunner.submit`/`.fail`.
* **🪶 Flexible Step Definition**: Define a step by passing its handler functions straight into `WorkflowStep.action(...)` — no subclass required for simple steps — fully interoperable with every decorator/composite above.
* **🔂 Sustained Steps**: `WorkflowStep.sustained(...)` models work with no natural completion of its own — a live stream subscription, an open connection, a polling loop — that runs until the step is cancelled or deactivated, without hand-rolling a `Completer`/`CancellationToken` dance per step.
* **🔒 Scoped Immutability**: `FlowContext`, the required base for every workflow's shared state, is a key-value store that makes data written by one step strictly read-only to every step that runs after it — enforced by the engine, not by convention.
* **🛑 Integrated Cancellation**: Simple cancellation tokens to abort workflows mid-flight when a user navigates away or manually cancels. `WorkflowStep.onDeactivateOrCancel` gives the actively-running step an immediate cleanup hook.
* **🔀 Concurrency Strategies**: `ManagedWorkflowRunner` governs what happens when a workflow is triggered again while already running — `ignore`, `cancelExisting`, or `enqueue` — plus `ParallelWorkflowRunner` for fully independent concurrent runs and `SharedWorkflowRunner` for merging multiple callers into one shared session.
* **📍 Live Step Progress**: `WorkflowRunner.progress` exposes a `ValueListenable<WorkflowProgress>` with the currently executing step id and the last known status of every step — drive a stepper/progress bar UI without hand-rolling counters in `WorkflowListener`.
* **📊 Auditing & Telemetry**: Lifecycle hooks (`WorkflowListener`) to seamlessly bind global loading indicators, telemetry, or debug logging.

---

## 📦 Installation

Add `maac_workflow` to your `pubspec.yaml`:

```yaml
dependencies:
  maac_workflow:
    path: packages/maac_workflow # For local melos workspaces
```

---

## 🛠️ Getting Started

### 1. Define your Workflow Context
Every `WorkflowRunner<TContext>` requires `TContext` to extend `FlowContext` — the
base every workflow's shared state builds on (see "Scoped Immutability with
`FlowContext`" further down for what it buys you). The simplest way to use it is
exactly like a regular mutable data class, just extending `FlowContext` instead
of nothing:

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
"Flexible Step Definition" further down.

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

## 🤝 Tightly Integrated with `maac_mvvm`

Clean MVVM architectures suggest keeping business orchestration separate from state representation. `maac_workflow` seamlessly integrates inside `maac_mvvm`'s `ViewModel` layer:

```dart
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_workflow/maac_workflow.dart';

class SignupViewModel extends ViewModel {
  final _cancellationToken = CancellationToken();
  final _loading = LiveData<bool>(false);
  LiveData<bool> get loading => _loading;

  final _signupWorkflow = WorkflowRunner<SignupContext>(
    steps: [
      RetryStepDecorator(step: CreateAccountStep(), maxAttempts: 2),
      ConditionalStep(
        id: 'conditional_upload_avatar',
        condition: (ctx) => ctx.hasAvatar,
        step: UploadAvatarStep(),
      ),
      SendWelcomeEmailStep(),
    ],
  );

  void startSignupFlow(SignupContext context) async {
    _loading.postValue(true);

    final result = await _signupWorkflow.run(
      context,
      cancellationToken: _cancellationToken,
    );

    _loading.postValue(false);

    switch (result) {
      case WorkflowSuccess():
        // Navigate or update success state
        break;
      case WorkflowFailure(:final failedStepId, :final error):
        // Show error dialog
        break;
      case WorkflowCancelled():
        // Log cancellation
        break;
    }
  }

  @override
  void onDispose() {
    // Automatically abort running workflows if user exits the screen and ViewModel disposes
    _cancellationToken.cancel();
    _signupWorkflow.dispose();
    super.onDispose();
  }
}
```

---

## ⏱️ Failing Slow Steps with `TimeoutStepDecorator`

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

## 🧩 Composing Large Flows with `WorkflowStepGroup`

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

---

## 🪶 Flexible Step Definition

Subclassing `WorkflowStep<T>` is still the right call for steps with their own
state or that get reused across flows, but for a step that's just a few lines,
`WorkflowStep.action(...)` skips the class entirely — it's fully interoperable
with every decorator/composite above, since it implements the exact same
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

---

## ⏸️ Interactive Steps: Pausing for UI Input

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
flows through `WorkflowRunner.progress` just like any other status (see below),
so a step indicator can render "waiting on you" differently from "running."

If the workflow is cancelled while a step is paused, the engine resolves it
immediately as a cancelled failure — no step author code is needed for this,
unlike a hand-rolled `Completer` where you'd have to remember to wire
`CancellationToken.onCancel` yourself.

---

## 🔒 Scoped Immutability with `FlowContext`

Every `TContext` extends `FlowContext`, which — beyond being a normal mutable
Dart object, as shown so far — is also a key-value store that can enforce a
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
input from a ViewModel) are always unrestricted and reset that key's
ownership, since this rule is about steps not stepping on each other, not
about the code that configures a run:

```dart
class SignupViewModel extends ViewModel {
  final _context = SignupContext();

  void startFlow() {
    _context.write('forceFailure', false); // fine — no step is active yet
    _signupWorkflow.run(_context);
  }
}
```

You don't have to use the store at all — plain mutable fields (as in the
Getting Started example above) work exactly as before and simply don't
participate in this tracking. Reach for the store when you specifically want
the engine to enforce read-only history for a piece of shared state.

---

## 📍 Tracking the Current Step & Per-Step Status

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

## 🔂 Single, Restartable Task (e.g. Stream Subscriptions)

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

Then use `ManagedWorkflowRunner` with `ConcurrencyStrategy.cancelExisting()` to get the
"cancel old, start new" bookkeeping for free — the same primitive works for any "only one
active at a time" scenario, not just streams: a single global loading indicator, a
debounced search request, etc. It takes a **factory**, not a fixed `WorkflowRunner`
instance — a fresh runner (and fresh step instances) is built for every logical run, since
`WorkflowRunner`/`InteractiveStep` hold per-instance mutable state that two overlapping
runs can never safely share:

```dart
class OrderTrackingViewModel extends ViewModel {
  final _watchOrder = ManagedWorkflowRunner<OrderTrackingContext>(
    createRunner: () => WorkflowRunner(steps: [watchOrderStatusStep]),
    strategy: const ConcurrencyStrategy.cancelExisting(),
  );

  void watchOrder(String orderId) {
    // Cancels whatever subscription is currently active — waiting for it to
    // fully settle, rollback included — before starting this one.
    _watchOrder.run(OrderTrackingContext(orderId: orderId, onStatusChanged: _handleStatusChanged));
  }

  @override
  void onResume() {
    // Screen became visible again: (re)start the subscription.
    watchOrder(currentOrderId);
    super.onResume();
  }

  @override
  void onPause() {
    // Screen no longer visible: stop the subscription. onResume() will start a
    // fresh one when the user comes back.
    _watchOrder.cancel();
    super.onPause();
  }
}
```

`ManagedWorkflowRunner` guarantees the invariant "at most one live subscription at a
time" by construction — no manual `CancellationToken`/`StreamSubscription` bookkeeping in
the ViewModel, no risk of leaking a forgotten listener.

---

## 🔀 Concurrency Strategies

`ManagedWorkflowRunner<TContext>` covers three of the five required behaviors for
"`run()` called again while already running" — pick one at construction via
`ConcurrencyStrategy`:

```dart
ManagedWorkflowRunner<TContext>({
  required WorkflowRunnerFactory<TContext> createRunner,
  required ConcurrencyStrategy strategy,
});
```

* **`ConcurrencyStrategy.ignore()`** — swallow the new call entirely; the in-flight run
  continues untouched, and the caller gets back that same run's `Future` (their own
  `context` argument is never used if a call gets swallowed).
* **`ConcurrencyStrategy.cancelExisting()`** — shown above: cancel the old run, wait for
  it to fully settle (rollback included), then start fresh.
* **`ConcurrencyStrategy.enqueue({int? maxQueueLength})`** — queue the new call; it runs
  once every call ahead of it has finished (success, failure, or cancellation), strictly
  FIFO. Exceeding `maxQueueLength` rejects only the excess call — like every other
  outcome in this package, by resolving immediately with a `WorkflowFailure` carrying a
  `QueueFullException` (never a thrown exception) — without disturbing the existing queue.

All three share the same `run(context) -> Future<WorkflowResult<TContext>>` shape, so
switching strategies at a call site is just swapping the `strategy:` argument.

The other two required behaviors don't fit that "one current run" shape, so they're
their own classes:

### `parallel`, via `ParallelWorkflowRunner`

Every call spins up a fully independent run — its own `WorkflowRunner`, its own isolated
`FlowContext` — running concurrently with any others rather than cancelling or queuing
them:

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

### `joinOrCreate`, via `SharedWorkflowRunner` + `JoinCompletionRule`

If nothing is running, starts a new session; if one's already in flight (e.g. a global
loading indicator), merges the new call into it instead of starting a second physical
run — avoiding duplicate work and UI flicker:

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

**If any joiner needs the real success/failure outcome rather than just an "something
happened" signal, use `waitAll`.** Under the other two rules, an early close can turn
every attached joiner's `result` into `WorkflowCancelled` regardless of how the work
would otherwise have turned out — appropriate for a pure UI signal (a shared spinner),
not for a result multiple callers actually depend on.

---

## 📡 Observing `FlowContext` Writes

`WorkflowListener` — already used for engine/step lifecycle events — also reports every
successful `context.write(...)` made during a run it's attached to:

```dart
class AnalyticsListener extends WorkflowListener<SignupContext> {
  @override
  void onContextWrite(String key, Object? value, String? writerStepId, SignupContext context) {
    analytics.track('flow_context_write', {'key': key, 'writerStepId': writerStepId});
  }
}
```

`writerStepId` is the id of whichever step made the write, or `null` for a write made
with no step active (before a run starts, after it finishes, or external seeding — see
"Scoped Immutability with `FlowContext`" above). Doesn't fire for a write that gets
rejected by scoped immutability (the `StateError` case) — only successful writes. Useful
for centralized logging, analytics, or a live debug/flow-visualizer screen, decoupled
from the steps' own business logic.
