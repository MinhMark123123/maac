import 'package:maac_workflow/maac_workflow.dart';

import 'notification_context.dart';
import 'sequential_api_view_model.dart';

class RequestNotificationPermissionStep extends WorkflowStep<NotificationPermissionContext> {
  final SequentialApiViewModel viewModel;
  RequestNotificationPermissionStep(this.viewModel);

  @override
  String get id => 'request_notification_permission';

  @override
  String get description => 'Background API: Ask the OS for notification permission';

  @override
  Future<StepResult> execute(NotificationPermissionContext context, CancellationToken token) async {
    viewModel.logEvent('[Notifications] Requesting permission...');
    await Future.delayed(const Duration(milliseconds: 800));
    token.throwIfCancelled();

    if (context.forceDeny) {
      viewModel.logEvent('[Notifications] User denied the permission prompt.');
      return StepFailure(Exception('Notification permission denied'));
    }

    context.granted = true;
    viewModel.logEvent('[Notifications] Permission granted!');
    return const StepSuccess();
  }
}
