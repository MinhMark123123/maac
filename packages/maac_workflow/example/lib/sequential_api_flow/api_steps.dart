import 'package:maac_workflow/maac_workflow.dart';

import 'api_context.dart';
import 'sequential_api_view_model.dart';

class FetchConfigStep extends WorkflowStep<ApiContext> {
  final SequentialApiViewModel viewModel;
  FetchConfigStep(this.viewModel);

  @override
  String get id => 'fetch_config';

  @override
  String get description => 'Background API: Fetch app remote configurations';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    viewModel.logEvent('Step 1 [Fetch Config]: Retrieving configurations...');
    await Future.delayed(const Duration(milliseconds: 1000));
    token.throwIfCancelled();

    context.config = const RemoteConfig(apiVersion: 'v3.4.0', maintenanceMode: false);
    viewModel.logEvent('Step 1 [Fetch Config]: Downloaded configs (apiVersion=${context.config!.apiVersion}).');
    return const StepSuccess();
  }
}

class FetchUserProfileStep extends WorkflowStep<ApiContext> {
  final SequentialApiViewModel viewModel;
  FetchUserProfileStep(this.viewModel);

  @override
  String get id => 'fetch_user_profile';

  @override
  String get description => 'Background API: Fetch profile (with optional Timeout decorator)';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    viewModel.logEvent('Step 2 [Fetch User Profile]: Fetching user metadata...');

    // Simulate delay. If forceProfileDelay is true, simulate a long response (e.g. 5 seconds)
    final delayMs = context.forceProfileDelay ? 5000 : 1000;
    final interval = 200;
    int elapsed = 0;

    while (elapsed < delayMs) {
      await Future.delayed(Duration(milliseconds: interval));
      token.throwIfCancelled();
      elapsed += interval;
    }

    context.profile = const UserProfile(displayName: 'Jane Doe', tier: 'gold');
    viewModel.logEvent('Step 2 [Fetch User Profile]: Loaded profile (${context.profile!.displayName}, tier=${context.profile!.tier}).');
    return const StepSuccess();
  }
}

class SyncDataStep extends WorkflowStep<ApiContext> {
  final SequentialApiViewModel viewModel;
  SyncDataStep(this.viewModel);

  @override
  String get id => 'sync_data';

  @override
  String get description => 'Background API: Sync local caches with remote (with Auto-Retry)';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    context.syncAttempts++;
    viewModel.logEvent('Step 3 [Sync Data]: Syncing files. Attempt #${context.syncAttempts}...');

    await Future.delayed(const Duration(milliseconds: 1200));
    token.throwIfCancelled();

    if (context.forceSyncFail) {
      viewModel.logEvent('Step 3 [Sync Data]: Attempt failed due to server connection issues.');
      return StepFailure(Exception('Sync failed (forced sync failure)'));
    }

    context.syncReport = SyncReport(syncedRecords: 128, syncedAt: DateTime.now());
    viewModel.logEvent('Step 3 [Sync Data]: Sync finalized (${context.syncReport!.syncedRecords} records).');
    return const StepSuccess();
  }
}
