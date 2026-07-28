import 'package:maac_workflow/maac_workflow.dart';

import '../common/callbacks.dart';
import '../data/notification_repository.dart';
import 'notification_context.dart';

class RequestNotificationPermissionStep extends WorkflowStep<NotificationPermissionContext> {
  final LogEvent logEvent;
  final NotificationRepository notificationRepository;
  RequestNotificationPermissionStep({required this.logEvent, required this.notificationRepository});

  @override
  String get id => 'request_notification_permission';

  @override
  String get description => 'Background API: Ask the OS for notification permission';

  @override
  Future<StepResult> execute(NotificationPermissionContext context, CancellationToken token) async {
    logEvent('[Notifications] Requesting permission...');
    try {
      await notificationRepository.requestPermission(forceDeny: context.forceDeny);
    } catch (e, stack) {
      token.throwIfCancelled();
      logEvent('[Notifications] User denied the permission prompt.');
      return StepFailure(e, stack);
    }
    token.throwIfCancelled();

    context.granted = true;
    logEvent('[Notifications] Permission granted!');
    return const StepSuccess();
  }
}
