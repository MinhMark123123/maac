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
///   - Widget? child: An optional child widget to be passed to the builder function.
///
/// Returns:
///   - A Widget that is built with the provided data and optional child.
typedef DataConsumerBuilder<Data> = Widget Function(
  BuildContext context,
  Data data,
  Widget? child,
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

  /// Creates a `StreamDataConsumer`.
  ///
  /// Parameters:
  ///   - streamData: The stream data source providing the stream of `Data`.
  ///   - builder: The builder function for creating the widget with updated data.
  const StreamDataConsumer({
    super.key,
    required this.streamData,
    required this.builder,
  });

  @override
  State<StreamDataConsumer<Data>> createState() =>
      _StreamDataConsumerState<Data>();
}

class _StreamDataConsumerState<Data> extends State<StreamDataConsumer<Data>> {
  Widget? cachedChild;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Data>(
      initialData: widget.streamData.data,
      stream: widget.streamData.asStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? widget.streamData.data;

        // Only update `cachedChild` if the new data is different
        if (cachedChild == null || snapshot.hasData) {
          cachedChild = widget.builder(context, data, cachedChild);
        }

        return cachedChild!;
      },
    );
  }
}
