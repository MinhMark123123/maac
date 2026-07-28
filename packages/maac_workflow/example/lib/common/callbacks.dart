/// A log-message sink. Pass a ViewModel's `logEvent` method (a tear-off) or
/// any compatible function — lets a `WorkflowStep` report progress without
/// depending on the concrete ViewModel type that happens to be driving it.
typedef LogEvent = void Function(String message);

/// Navigates to [location] (a route path). Same rationale as [LogEvent]:
/// decouples a `WorkflowStep` from any particular ViewModel/router.
typedef Navigate = void Function(String location);
