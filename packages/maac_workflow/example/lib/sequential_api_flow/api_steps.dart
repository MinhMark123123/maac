import 'package:maac_workflow/maac_workflow.dart';

import '../common/callbacks.dart';
import '../data/api_repository.dart';
import 'api_context.dart';

class FetchConfigStep extends WorkflowStep<ApiContext> {
  final LogEvent logEvent;
  final ApiRepository apiRepository;
  FetchConfigStep({required this.logEvent, required this.apiRepository});

  @override
  String get id => 'fetch_config';

  @override
  String get description => 'Background API: Fetch app remote configurations';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    logEvent('Step 1 [Fetch Config]: Retrieving configurations...');
    context.config = await apiRepository.fetchConfig();
    token.throwIfCancelled();

    logEvent('Step 1 [Fetch Config]: Downloaded configs (apiVersion=${context.config!.apiVersion}).');
    return const StepSuccess();
  }
}

class FetchUserProfileStep extends WorkflowStep<ApiContext> {
  final LogEvent logEvent;
  final ApiRepository apiRepository;
  FetchUserProfileStep({required this.logEvent, required this.apiRepository});

  @override
  String get id => 'fetch_user_profile';

  @override
  String get description => 'Background API: Fetch profile (with optional Timeout decorator)';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    logEvent('Step 2 [Fetch User Profile]: Fetching user metadata...');

    context.profile = await apiRepository.fetchUserProfile(token, forceDelay: context.forceProfileDelay);

    logEvent('Step 2 [Fetch User Profile]: Loaded profile (${context.profile!.displayName}, tier=${context.profile!.tier}).');
    return const StepSuccess();
  }
}

class SyncDataStep extends WorkflowStep<ApiContext> {
  final LogEvent logEvent;
  final ApiRepository apiRepository;
  SyncDataStep({required this.logEvent, required this.apiRepository});

  @override
  String get id => 'sync_data';

  @override
  String get description => 'Background API: Sync local caches with remote (with Auto-Retry)';

  @override
  Future<StepResult> execute(ApiContext context, CancellationToken token) async {
    context.syncAttempts++;
    logEvent('Step 3 [Sync Data]: Syncing files. Attempt #${context.syncAttempts}...');

    final SyncReport report;
    try {
      report = await apiRepository.syncData(forceFail: context.forceSyncFail);
    } catch (e, stack) {
      token.throwIfCancelled(); // cancellation, not a business failure — let it propagate as such
      logEvent('Step 3 [Sync Data]: Attempt failed due to server connection issues.');
      return StepFailure(e, stack);
    }
    token.throwIfCancelled();

    context.syncReport = report;
    logEvent('Step 3 [Sync Data]: Sync finalized (${context.syncReport!.syncedRecords} records).');
    return const StepSuccess();
  }
}
