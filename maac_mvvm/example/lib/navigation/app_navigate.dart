import 'package:go_router/go_router.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class AppNavigate extends DelegateNavigation {
  AppNavigate({required super.context});

  @override
  bool canPop() {
    return context.canPop();
  }

  @override
  void dispose() {
    GoRouter.of(context).dispose();
  }

  @override
  void go(String location, {Object? extra}) {
    return context.go(location, extra: extra);
  }

  @override
  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    return context.goNamed(
      name,
      params: params,
      queryParams: queryParams,
      extra: extra,
    );
  }

  @override
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    return context.namedLocation(name, params: params, queryParams: queryParams);
  }

  @override
  Future<dynamic> pop() async {
    context.pop();
  }

  @override
  Future<dynamic> push(String location, {Object? extra}) async {
    context.push(location, extra: extra);
  }

  @override
  Future<dynamic> pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) async {
    context.pushNamed(name, params: params, queryParams: queryParams, extra: extra);
  }

  @override
  Future<dynamic> refresh() async {
    GoRouter.of(context).refresh();
  }

  @override
  void replace(String location, {Object? extra}) {
    context.replace(location, extra: extra);
  }

  @override
  void replaceNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    context.replaceNamed(name, params: params, queryParams: queryParams, extra: extra);
  }
}
