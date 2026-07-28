import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

part 'logging_view_model.g.dart';

/// Base for demo ViewModels that maintain a rolling, timestamped event log
/// for the UI's telemetry panel — `logEvent`/`clearLogs` live here once
/// instead of being copy-pasted into every flow's ViewModel.
///
/// Concrete subclasses still declare their own `@Bind()` field for the log
/// itself (e.g. `@Bind() late final _workflowHistory = <String>[].mtd(this);`)
/// — the `@BindableViewModel()` generator only scans fields declared
/// directly on the class it's processing, not ones inherited from a base
/// class — and expose it via [eventLog]. That's a deliberately different
/// name from the generator's own public `workflowHistory` getter (emitted
/// from the `@Bind()` field) so the two don't collide.

@BindableViewModel()
abstract class LoggingViewModel extends ViewModel {
  @Bind()
  late final _eventLog = <String>[].mtd(this);

  void logEvent(String msg) {
    final list = List<String>.from(eventLog.data);
    list.add('[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $msg');
    _eventLog.postValue(list);
  }

  void clearLogs() => _eventLog.postValue([]);
}
