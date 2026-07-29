import 'dart:async';

import 'package:maac_workflow/maac_workflow.dart';

/// Visual status of one tracked click for the tracker list UI.
enum ExecutionStatus { active, cancelled, completed }

/// Shared state for a single-flight ticker-watching run: which click started
/// it, and the live subscription its step tears down on cancel/deactivate.
class SimpleStreamContext extends FlowContext {
  final int clickIndex;
  StreamSubscription? subscription;

  SimpleStreamContext(this.clickIndex);
}

class ExecutionTracker {
  final int clickIndex;
  final DateTime timestamp;
  ExecutionStatus status;
  String? result;

  ExecutionTracker(this.clickIndex) : timestamp = DateTime.now(), status = ExecutionStatus.active;
}
