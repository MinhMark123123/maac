import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class StreamDataConsumer<Data> extends StatelessWidget {
  final StreamData<Data> _streamData;
  final Widget Function(BuildContext context, Data data) _builder;

  const StreamDataConsumer({
    Key? key,
    required StreamData<Data> streamData,
    required Widget Function(BuildContext context, Data data) builder,
  })  : _streamData = streamData,
        _builder = builder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Data>(
      initialData: _streamData.data,
      stream: _streamData.asStream(),
      builder: (context, snapshot) {
        return _builder(context, _streamData.data);
      },
    );
  }
}