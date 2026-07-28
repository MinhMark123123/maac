import 'package:maac_workflow/maac_workflow.dart';

/// Context for a second, unrelated pipeline running on the same screen as
/// the Config/Profile/Sync pipeline — deliberately a different type than
/// [ApiContext] (see `api_context.dart`), to prove a screen can host more
/// than one `WorkflowRunner` with more than one `TContext`.
class NotificationPermissionContext extends FlowContext {
  bool granted = false;
  bool forceDeny = false;
}
