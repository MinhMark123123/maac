import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

/// A typedef for a builder function that is used to create a widget
/// that consumes data from a stream. The builder function is called
/// each time new data is emitted by the stream.
///
/// Type Parameters:
///   - Data: The type of data that the Stream emits.
///
/// Parameters:
///   - BuildContext context: The build context in which the widget is built.
///   - Data data: The latest data emitted by the Stream.
///
/// Returns:
///   - A Widget that is built with the provided data and optional child.
typedef DataConsumerBuilder<Data> = Widget Function(
  BuildContext context,
  Data data,
);

/// A stateless widget that listens to a stream of data (`StreamData`) and
/// rebuilds the UI each time new data is emitted. It uses a `DataConsumerBuilder`
/// function to build the UI with the updated data.
///
/// This widget is useful for consuming a stream of data and updating the UI
/// reactively based on the latest emitted data.
///
/// Type Parameters:
///   - Data: The type of data being consumed from the stream.
class StreamDataConsumer<Data> extends StatefulWidget {
  /// The [streamData] instance that provides the data stream. It contains
  /// both the current data and the stream that emits data updates.
  final StreamData<Data> streamData;

  /// The builder function that is used to construct the widget each time
  /// new data is emitted by the stream.
  final DataConsumerBuilder<Data> builder;

  /// Optional predicate evaluated against every newly emitted value. When it
  /// returns `true`, this widget reuses the previously built child instead
  /// of calling [builder] again — useful for values that shouldn't visually
  /// affect the UI (e.g. a transient/no-op state) without silencing the
  /// stream itself. Has no effect until a first child has actually been
  /// built (nothing to reuse yet).
  final bool Function(Data value)? useCache;

  /// Creates a `StreamDataConsumer`.
  ///
  /// Parameters:
  ///   - streamData: The stream data source providing the stream of `Data`.
  ///   - builder: The builder function for creating the widget with updated data.
  ///   - useCache: Optional predicate to skip rebuilding for certain values.
  const StreamDataConsumer({
    super.key,
    required this.streamData,
    required this.builder,
    this.useCache,
  });

  @override
  State<StreamDataConsumer<Data>> createState() =>
      _StreamDataConsumerState<Data>();
}

class _StreamDataConsumerState<Data> extends State<StreamDataConsumer<Data>> {
  Widget? _cachedChild;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Data>(
      initialData: widget.streamData.data,
      stream: widget.streamData.asStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? widget.streamData.data;
        final cachedChild = _cachedChild;
        if (cachedChild != null && (widget.useCache?.call(data) ?? false)) {
          return cachedChild;
        }
        final child = widget.builder(context, data);
        _cachedChild = child;
        return child;
      },
    );
  }
}

/// A typedef for a builder function that combines the latest data of 2
/// [StreamData] sources. Called on every rebuild triggered by
/// [StreamDataConsumer2] — see [MergeStreamDataConsumer] for the merge
/// semantics.
typedef DataConsumerBuilder2<A, B> = Widget Function(
  BuildContext context,
  A a,
  B b,
);

/// Rebuilds whenever either [streamData1] or [streamData2] emits, passing
/// both of their latest [StreamData.data] values to [builder]. A thin,
/// type-safe wrapper around [MergeStreamDataConsumer] for the common
/// 2-source case.
///
/// ```dart
/// StreamDataConsumer2<bool, String?>(
///   streamData1: viewModel.isLoading,
///   streamData2: viewModel.errorMessage,
///   builder: (context, isLoading, errorMessage) {
///     if (isLoading) return const LoadingIndicator();
///     if (errorMessage != null) return ErrorBanner(errorMessage);
///     return const SizedBox.shrink();
///   },
/// )
/// ```
class StreamDataConsumer2<A, B> extends StatelessWidget {
  /// The first [StreamData] source.
  final StreamData<A> streamData1;

  /// The second [StreamData] source.
  final StreamData<B> streamData2;

  /// The builder function called with both sources' latest data.
  final DataConsumerBuilder2<A, B> builder;

  /// Creates a `StreamDataConsumer2`.
  const StreamDataConsumer2({
    super.key,
    required this.streamData1,
    required this.streamData2,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return MergeStreamDataConsumer(
      streams: [streamData1, streamData2],
      builder: (context) => builder(context, streamData1.data, streamData2.data),
    );
  }
}

/// A typedef for a builder function that combines the latest data of 3
/// [StreamData] sources. Called on every rebuild triggered by
/// [StreamDataConsumer3] — see [MergeStreamDataConsumer] for the merge
/// semantics.
typedef DataConsumerBuilder3<A, B, C> = Widget Function(
  BuildContext context,
  A a,
  B b,
  C c,
);

/// Rebuilds whenever [streamData1], [streamData2], or [streamData3] emits,
/// passing all three of their latest [StreamData.data] values to [builder].
/// A thin, type-safe wrapper around [MergeStreamDataConsumer] for the common
/// 3-source case.
class StreamDataConsumer3<A, B, C> extends StatelessWidget {
  /// The first [StreamData] source.
  final StreamData<A> streamData1;

  /// The second [StreamData] source.
  final StreamData<B> streamData2;

  /// The third [StreamData] source.
  final StreamData<C> streamData3;

  /// The builder function called with all three sources' latest data.
  final DataConsumerBuilder3<A, B, C> builder;

  /// Creates a `StreamDataConsumer3`.
  const StreamDataConsumer3({
    super.key,
    required this.streamData1,
    required this.streamData2,
    required this.streamData3,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return MergeStreamDataConsumer(
      streams: [streamData1, streamData2, streamData3],
      builder: (context) => builder(context, streamData1.data, streamData2.data, streamData3.data),
    );
  }
}
