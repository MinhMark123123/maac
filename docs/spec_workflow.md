# 🔀 API Specification: `maac_workflow`

`maac_workflow` is a step-pipeline orchestration engine for Flutter. It sits below the `ViewModel` in the
MAAC stack — where `maac_mvvm` handles UI state and lifecycle, `maac_workflow` handles multi-step
business logic (rollback on failure, cancellation, retries, concurrency) that would otherwise turn a
`ViewModel` method into hand-rolled try/catch/undo spaghetti.

Minimal architecture: **`ViewModel` → `Workflow` (`WorkflowStep` + `WorkflowRunner`) → `Repository`** — a
`WorkflowStep` plays roughly the role of a Clean Architecture `UseCase`, except `WorkflowRunner` absorbs
the orchestration (rollback, retry, cancellation, progress) that's usually hand-coded in the ViewModel.

---

## 📦 Installation

```bash
flutter pub add maac_workflow
```

---

## 🧱 Core Building Blocks

### `FlowContext`
A plain key-value store shared across every step of a run, enforcing **scoped immutability**: once a key
is written by a step, only that same step may write it again (e.g. from its own `rollback`) — every other
step gets read-only access, enforced by the engine, not convention.

```dart
class SignupContext extends FlowContext {} // subclass only to attach typed extension getters/setters
```

### `WorkflowStep<TContext>`
One unit of work. Subclass it, or define one inline via `WorkflowStep.action(...)` for simple cases:

```dart
final step = WorkflowStep<MyContext>.action(
  id: 'fetch_profile',
  execute: (context, token) async { ...; return const StepSuccess(); },
  rollback: (context) async { /* undo */ },
);
```

### `WorkflowRunner<TContext extends FlowContext>`
Runs a `List<WorkflowStep<TContext>>` in order. If a step fails, every step that already succeeded is
rolled back automatically, in reverse (LIFO) order — no manual try/catch/undo bookkeeping.

```dart
final result = await WorkflowRunner<MyContext>(steps: [stepA, stepB]).run(context);
switch (result) {
  case WorkflowSuccess(): ...
  case WorkflowFailure(:final failedStepId, :final error): ...
  case WorkflowCancelled(): ...
}
```

---

## 🪶 Step Definition Variants

| Variant | Use for |
| :--- | :--- |
| `WorkflowStep.action(...)` | Simple steps — a function, no subclass needed. |
| `WorkflowStep.sustained(start:, stop:)` | Work with no natural completion (a stream subscription, an open connection) — runs until cancelled/deactivated. |
| `InteractiveStep<TContext, TInput>` | A step that pauses for external input (typically a UI form) — resume via `WorkflowRunner.submit`/`.fail`. |

---

## 🧩 Composites & Decorators

All of these are themselves `WorkflowStep`s, so they compose freely with each other and with the plain
steps above:

- **`ConditionalStep`** — runs a step only if a predicate over the context is true.
- **`WorkflowStepGroup`** — embeds a whole sub-pipeline as a single step.
- **`ParallelStepGroup`** — runs independent sub-steps concurrently as a single step.
- **`RetryStepDecorator`** — retries a brittle step with a configurable backoff policy.
- **`TimeoutStepDecorator`** — fails a step that runs longer than a given duration, without cancelling the whole run.

---

## 🛑 Cancellation

Every `run()` carries a `CancellationToken` (created automatically, or passed in to control externally).
Steps check it cooperatively:

```dart
execute: (context, token) async {
  for (final chunk in chunks) {
    await doWork(chunk);
    token.throwIfCancelled(); // stops between units of work, not mid-instruction
  }
  return const StepSuccess();
}
```
`WorkflowStep.onDeactivateOrCancel` gives the actively-running step an immediate cleanup hook the instant
`cancel()` fires, regardless of whether `execute()` has resolved yet.

---

## 📍 Progress & 📊 Observability

- **`WorkflowRunner.progress`** — a `ValueListenable<WorkflowProgress>` with the current step id and the
  last known `StepStatus` of every step. Drive a stepper UI without hand-rolled counters.
- **`WorkflowListener<TContext>`** — lifecycle hooks (`onStepStart`/`onStepSuccess`/`onStepFailure`/
  rollback events/`onWorkflowSuccess`/`onWorkflowFailure`) plus `onContextWrite`, which fires on every
  successful `context.write(...)` — telemetry and global loading indicators stay out of step bodies
  entirely.

---

## 🔀 Concurrency

For "what happens if `run()` is triggered again while already running" — five configs, three wrapper
classes:

| Wrapper | Configs | Use for |
| :--- | :--- | :--- |
| `ManagedWorkflowRunner` + `ConcurrencyStrategy` | `.ignore()`, `.cancelExisting()`, `.enqueue()` | Exactly one logical run "owns" the runner at a time. |
| `ParallelWorkflowRunner` | — | N simultaneous, fully independent runs (returns a `ParallelRunHandle` per call). |
| `SharedWorkflowRunner` + `JoinCompletionRule` | `.waitAll`, `.overrideByLatest`, `.firstWins` | Multiple callers merged into one shared physical run (`join()`/`leave()`). |

```dart
final runner = ManagedWorkflowRunner<MyContext>(
  createRunner: () => WorkflowRunner(steps: [...]), // factory — fresh runner per logical run
  strategy: const ConcurrencyStrategy.cancelExisting(),
);
```
All three take a **factory**, not a fixed `WorkflowRunner` instance — `WorkflowRunner`/`InteractiveStep`
hold per-instance mutable state that two overlapping runs can never safely share.

---

## 🗺️ Where to Go Next

- **[`maac_workflow` package README](../packages/maac_workflow/README.md)** — the full spec, with a
  runnable code sample for every concept above.
- **Example app → Basics** (`packages/maac_workflow/example`) — one minimal, focused screen per concept
  listed above (`FlowContext`, sequential run + rollback, `CancellationToken`, `WorkflowListener`, …),
  deliberately bare of UI chrome so each one reads as "just the API".
- **Example app → Signup / Sequential API / Single-Flight flows** — fuller showcases combining several
  concepts into one realistic screen (interactive multi-step forms, decorators, single-flight cancellation).
