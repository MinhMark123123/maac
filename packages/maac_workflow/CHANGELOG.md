## 0.1.1

 - **FEAT**: implement merge consumer (#50).

## 0.1.0

* Initial release: `WorkflowRunner`/`WorkflowStep` sequential pipeline with LIFO rollback, `FlowContext` scoped immutability, `CancellationToken`, and `WorkflowListener`.
* Step definitions: `WorkflowStep.action`, `WorkflowStep.sustained`, `InteractiveStep`.
* Composites & decorators: `ConditionalStep`, `WorkflowStepGroup`, `ParallelStepGroup`, `RetryStepDecorator`, `TimeoutStepDecorator`.
* Live progress via `WorkflowRunner.progress`.
* Concurrency: `ManagedWorkflowRunner` + `ConcurrencyStrategy` (`ignore`/`cancelExisting`/`enqueue`), `ParallelWorkflowRunner`, `SharedWorkflowRunner` + `JoinCompletionRule` (`waitAll`/`overrideByLatest`/`firstWins`).
