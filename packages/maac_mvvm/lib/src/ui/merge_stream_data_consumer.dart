import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

/// A builder function called on every rebuild triggered by
/// [MergeStreamDataConsumer]. Unlike [DataConsumerBuilder], it doesn't carry
/// a payload — read whichever [StreamData.data] you need directly, since
/// they're already up to date by the time this is called.
typedef MergedDataBuilder = Widget Function(BuildContext context);

/// A stateless-in-spirit widget that rebuilds whenever **any** of [streams]
/// emits, without pairing up or waiting on the others — the merge semantics
/// of `package:async`'s `StreamGroup.mergeBroadcast`, applied to
/// [StreamData]. Since each [StreamData] already tracks its own latest
/// [StreamData.data] synchronously, [builder] doesn't need a combined
/// payload — it just needs to know "something changed, rebuild".
///
/// This is the primitive [StreamDataConsumer2] and [StreamDataConsumer3] are
/// built on top of. Reach for it directly when you need to combine more than
/// 3 sources, or sources you don't know the count of ahead of time:
///
/// ```dart
/// MergeStreamDataConsumer(
///   streams: [viewModel.isLoading, viewModel.errorMessage],
///   builder: (context) {
///     if (viewModel.isLoading.data) return const LoadingIndicator();
///     if (viewModel.errorMessage.data != null) return ErrorBanner(viewModel.errorMessage.data!);
///     return const SizedBox.shrink();
///   },
/// )
/// ```
class MergeStreamDataConsumer extends StatefulWidget {
  /// The [StreamData] sources to merge. A rebuild is triggered whenever any
  /// one of them emits, regardless of the others.
  final List<StreamData<Object?>> streams;

  /// The builder function called on every merged rebuild.
  final MergedDataBuilder builder;

  /// Creates a `MergeStreamDataConsumer`.
  ///
  /// Parameters:
  ///   - streams: The [StreamData] sources to merge.
  ///   - builder: The builder function called on every merged rebuild.
  const MergeStreamDataConsumer({
    super.key,
    required this.streams,
    required this.builder,
  });

  @override
  State<MergeStreamDataConsumer> createState() => _MergeStreamDataConsumerState();
}

class _MergeStreamDataConsumerState extends State<MergeStreamDataConsumer> {
  late final Stream<Object?> _merged = StreamGroup.mergeBroadcast<Object?>(
    widget.streams.map((streamData) => streamData.asStream()),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object?>(
      stream: _merged,
      builder: (context, snapshot) => widget.builder(context),
    );
  }
}
