import 'package:maac_workflow/maac_workflow.dart';

/// Config payload returned by `FetchConfigStep`.
class RemoteConfig {
  final String apiVersion;
  final bool maintenanceMode;

  const RemoteConfig({required this.apiVersion, required this.maintenanceMode});
}

/// Profile payload returned by `FetchUserProfileStep` — a different shape
/// than [RemoteConfig], on purpose.
class UserProfile {
  final String displayName;
  final String tier;

  const UserProfile({required this.displayName, required this.tier});
}

/// Sync summary returned by `SyncDataStep` — again, its own shape.
class SyncReport {
  final int syncedRecords;
  final DateTime syncedAt;

  const SyncReport({required this.syncedRecords, required this.syncedAt});
}

/// Shared state that flows through the sequential API demo pipeline.
///
/// `WorkflowStep.execute()` always returns `StepResult` — the engine doesn't
/// propagate a typed value between steps. So when steps produce
/// differently-shaped results (a config blob, a profile, a sync report),
/// each step writes its own typed field onto this shared context instead;
/// later steps (or the ViewModel) just read whichever fields they need.
///
/// Extends `FlowContext` (required by `WorkflowRunner<TContext>`'s bound)
/// but doesn't use its key-value store — plain mutable fields, same as
/// before `FlowContext` existed. See `signup_flow`'s `signup_context.dart`
/// for an example that does use the store.
class ApiContext extends FlowContext {
  RemoteConfig? config;
  UserProfile? profile;
  SyncReport? syncReport;

  int syncAttempts = 0;

  // Configurations from UI
  bool forceProfileDelay = false;
  bool forceSyncFail = false;
}
