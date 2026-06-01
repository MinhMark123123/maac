# maac_workflow

A highly resilient, stateful, and declarative asynchronous workflow and step pipeline orchestration engine for Dart & Flutter.

---

## 🌟 Overview

In modern Flutter applications, business processes such as **eKYC, complex registration flows, sequential API setups, or multi-step checkout processes** are often written directly inside ViewModels or UI widgets. This inevitably leads to:
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
* **🛑 Integrated Cancellation**: Simple cancellation tokens to abort workflows mid-flight when a user navigates away or manually cancels.
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
class EkycContext {
  String? frontCardPath;
  String? backCardPath;
  String? uploadedFrontUrl;
  String? uploadedBackUrl;
  Map<String, dynamic>? ocrData;
  bool isCompleted = false;

  bool get needsManualVerification => (ocrData?['confidence'] ?? 0.0) < 0.90;
}
```

### 2. Implement Your Steps
Inherit from `WorkflowStep<T>` to implement individual operations. Optionally implement `rollback` to support compensation if subsequent steps fail.

```dart
class UploadFrontCardStep extends WorkflowStep<EkycContext> {
  @override
  String get id => 'upload_front_card';

  @override
  Future<StepResult<void>> execute(EkycContext context, CancellationToken token) async {
    try {
      // Simulate API upload call
      await Future.delayed(const Duration(seconds: 2));
      context.uploadedFrontUrl = 'https://cloud.storage/front.jpg';
      return const StepSuccess(null);
    } catch (e, stack) {
      return StepFailure(e, stack);
    }
  }

  @override
  Future<void> rollback(EkycContext context) async {
    // If upload was successful, but a later step fails, delete the file to prevent orphaned cloud resources.
    if (context.uploadedFrontUrl != null) {
      await cloudStorage.delete(context.uploadedFrontUrl!);
      context.uploadedFrontUrl = null;
    }
  }
}
```

### 3. Orchestrate and Run the Workflow
Run your pipeline declaratively. Wrap brittle steps with retry decorators, and conditionally execute steps.

```dart
final ekycWorkflow = WorkflowRunner<EkycContext>(
  steps: [
    // Automatically retry upload up to 3 times with exponential backoff on network issues
    RetryStepDecorator(
      step: UploadFrontCardStep(),
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 1),
    ),
    OcrStep(),
    // Branching: only execute manual verification step if predicate returns true
    ConditionalStep(
      id: 'conditional_manual_verification',
      condition: (ctx) => ctx.needsManualVerification,
      step: ManualVerificationStep(),
    ),
    SubmitRegistrationStep(),
  ],
);

// Execute the workflow
final result = await ekycWorkflow.run(EkycContext());

// Safely pattern match results using Dart 3 sealed class capabilities
switch (result) {
  case WorkflowSuccess():
    print('Workflow Completed Successfully!');
  case WorkflowFailure(:final failedStepId, :final error):
    print('Failed at step [$failedStepId] with error: $error');
  case WorkflowCancelled():
    print('Workflow was cancelled.');
}
```

---

## 🤝 Tightly Integrated with `maac_mvvm`

Clean MVVM architectures suggest keeping business orchestration separate from state representation. `maac_workflow` seamlessly integrates inside `maac_mvvm`'s `ViewModel` layer:

```dart
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_workflow/maac_workflow.dart';

class EkycViewModel extends ViewModel {
  final _cancellationToken = CancellationToken();
  final _loading = LiveData<bool>(false);
  LiveData<bool> get loading => _loading;

  final _ekycWorkflow = WorkflowRunner<EkycContext>(
    steps: [
      RetryStepDecorator(step: UploadFrontCardStep(), maxAttempts: 2),
      OcrStep(),
      SubmitRegistrationStep(),
    ],
  );

  void startEkycFlow(EkycContext context) async {
    _loading.postValue(true);

    final result = await _ekycWorkflow.run(
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
