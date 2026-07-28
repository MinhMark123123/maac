import 'package:maac_workflow/maac_workflow.dart';

import '../sequential_api_flow/api_context.dart';
import 'simulated_delay.dart';

/// Simulates the config/profile/sync backend calls behind the sequential API
/// demo — network delay and fake payloads, plus whichever mock failure/delay
/// scenario the caller asks for via each method's own arguments (mirroring
/// how a real backend can be told, or happen, to behave badly).
class ApiRepository {
  Future<RemoteConfig> fetchConfig() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return const RemoteConfig(apiVersion: 'v3.4.0', maintenanceMode: false);
  }

  /// [forceDelay] simulates a slow response (e.g. to demonstrate
  /// `TimeoutStepDecorator`). Checks [token] every 200ms during the wait, so
  /// cancelling mid-request is noticed promptly even during a long delay.
  Future<UserProfile> fetchUserProfile(CancellationToken token, {required bool forceDelay}) async {
    await simulateCancellableDelay(Duration(milliseconds: forceDelay ? 5000 : 1000), token);
    return const UserProfile(displayName: 'Jane Doe', tier: 'gold');
  }

  /// [forceFail] simulates a server-side sync error (e.g. to demonstrate
  /// `RetryStepDecorator` retrying, then eventually giving up).
  Future<SyncReport> syncData({required bool forceFail}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (forceFail) {
      throw Exception('Sync failed (forced sync failure)');
    }
    return SyncReport(syncedRecords: 128, syncedAt: DateTime.now());
  }
}
