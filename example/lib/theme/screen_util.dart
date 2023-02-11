/*
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool _defaultRebuildFactor(MediaQueryData old, MediaQueryData data) =>
    old.size != data.size;

class KCSScreenUtilInit extends StatefulWidget {
  static const Size _defaultDesignSize = Size(375, 667);

  const KCSScreenUtilInit({
    Key? key,
    this.builder,
    this.child,
    this.rebuildFactor = _defaultRebuildFactor,
    this.designSize = _defaultDesignSize,
    this.splitScreenMode = false,
    this.minTextAdapt = false,
    this.useInheritedMediaQuery = false,
  })  : assert(
          builder != null || child != null,
          'You must either pass builder or child or both',
        ),
        super(key: key);

  final Widget Function(Widget? child)? builder;
  final Widget? child;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final RebuildFactor rebuildFactor;

  /// The [Size] of the device in the design draft, in dp
  final Size designSize;

  @override
  State<KCSScreenUtilInit> createState() => _KCSScreenUtilInitState();
}

class _KCSScreenUtilInitState extends State<KCSScreenUtilInit>
    with WidgetsBindingObserver {
  late MediaQueryData mediaQueryData;
  bool wrappedInMediaQuery = false;

  WidgetsBinding get binding => WidgetsFlutterBinding.ensureInitialized();

  MediaQueryData get newData {
    if (widget.useInheritedMediaQuery) {
      final el = context.getElementForInheritedWidgetOfExactType<MediaQuery>();
      final mq = el?.widget as MediaQuery?;
      final data = mq?.data;

      if (data != null) {
        wrappedInMediaQuery = true;
        return data;
      }
    }
    // Setting font does not change with system font size
    return MediaQueryData.fromWindow(binding.window)
        .copyWith(textScaleFactor: 1.0);
  }

  Widget get child {
    return SizedBox(
      key: GlobalObjectKey(
        Object.hash(
          mediaQueryData.size.width,
          mediaQueryData.size.height,
        ),
      ),
      child: widget.builder?.call(widget.child) ?? widget.child!,
    );
  }

  @override
  void initState() {
    super.initState();
    mediaQueryData = newData;
    binding.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final old = mediaQueryData;
    final data = newData;

    if (widget.rebuildFactor(old, data)) setState(() => mediaQueryData = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    didChangeMetrics();
  }

  @override
  void dispose() {
    binding.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mediaQueryData.size == Size.zero) return const SizedBox.shrink();
    if (!wrappedInMediaQuery) {
      return MediaQuery(
        // key: GlobalObjectKey('mediaQuery'),
        data: mediaQueryData,
        child: Builder(
          builder: (_) {
            ScreenUtil.init(
              context,
              designSize: widget.designSize,
              splitScreenMode: widget.splitScreenMode,
              minTextAdapt: widget.minTextAdapt,
            );
            return child;
          },
        ),
      );
    }
    ScreenUtil.init(
      context,
      designSize: widget.designSize,
      splitScreenMode: widget.splitScreenMode,
      minTextAdapt: widget.minTextAdapt,
    );
    return child;
  }
}
*/
