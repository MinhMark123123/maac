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
  * `ParallelStep` to run independent asynchronous steps concurrently.
  * `RetryStepDecorator` to automatically retry brittle steps with custom delay policies (e.g., Exponential Backoff).
  * `TimeoutStepDecorator` to fail a step that runs longer than expected, without cancelling the whole workflow.
  * `WorkflowStepGroup` to embed a whole sub-pipeline as a single step, so large flows compose out of smaller, named, independently testable ones.
* **🛑 Integrated Cancellation**: Simple cancellation tokens to abort workflows mid-flight when a user navigates away or manually cancels.
* **🔂 Single-Flight Execution**: `SingleFlightWorkflowRunner` guarantees at most one run of a workflow is ever active at a time, cancelling the previous one whenever a new one starts.
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
Create a data class that holds the input, intermediate, and output state of your workflow.

```dart
class SignupContext {
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
  Future<StepResult<void>> execute(SignupContext context, CancellationToken token) async {
    try {
      // Simulate API call to create the account
      final userId = await authApi.createAccount(context.email, context.password);
      context.userId = userId;
      return const StepSuccess(null);
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

## 🔂 Single, Restartable Task (e.g. Stream Subscriptions)

A common screen-level pattern: only **one** active subscription should ever be alive at a
time. Start watching when the screen is shown, stop when it's paused or disposed, and if
the target changes (e.g. switching chat rooms), cancel the previous subscription *before*
starting the new one — never let two run concurrently.

Model the subscription itself as a `WorkflowStep` that never completes on its own — its
`execute` future only resolves once the `CancellationToken` passed into it is cancelled:

```dart
class WatchOrderStatusStep extends WorkflowStep<OrderTrackingContext> {
  @override
  String get id => 'watch_order_status';

  @override
  Future<StepResult<void>> execute(OrderTrackingContext context, CancellationToken token) {
    final completer = Completer<StepResult<void>>();
    late final StreamSubscription<OrderStatus> subscription;

    // Stop listening the instant the token is cancelled — either because the screen
    // paused/disposed, or a newer subscription superseded this one.
    token.onCancel(() {
      subscription.cancel();
      if (!completer.isCompleted) completer.complete(const StepSuccess(null));
    });

    subscription = orderRepository.watchStatus(context.orderId).listen(
      context.onStatusChanged,
      onError: (e, stack) {
        if (!completer.isCompleted) completer.complete(StepFailure(e, stack));
      },
    );

    return completer.future;
  }
}
```

Then use `SingleFlightWorkflowRunner` to get the "cancel old, start new" bookkeeping
for free — the same primitive works for any "only one active at a time" scenario, not
just streams: a single global loading indicator, a debounced search request, etc.

```dart
class OrderTrackingViewModel extends ViewModel {
  final _watchOrder = SingleFlightWorkflowRunner<OrderTrackingContext>(
    WorkflowRunner(steps: [WatchOrderStatusStep()]),
  );

  void watchOrder(String orderId) {
    // Cancels whatever subscription is currently active before starting this one.
    _watchOrder.run(OrderTrackingContext(orderId: orderId));
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

  @override
  void onDispose() {
    _watchOrder.cancel();
    super.onDispose();
  }
}
```

`SingleFlightWorkflowRunner` guarantees the invariant "at most one live subscription
at a time" by construction — no manual `CancellationToken`/`StreamSubscription`
bookkeeping in the ViewModel, no risk of leaking a forgotten listener.
