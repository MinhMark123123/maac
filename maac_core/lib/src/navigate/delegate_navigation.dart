import 'package:flutter/widgets.dart';

abstract class DelegateNavigation {
  final BuildContext? _context;

  BuildContext get context => _context!;

  DelegateNavigation({required BuildContext? context}) : _context = context;

  bool canPop();

  void dispose();

  void go(String location, {Object? extra});

  void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  });

  Future<dynamic> pop();

  Future<dynamic> push(String location, {Object? extra});

  Future<dynamic> pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  Future<dynamic> refresh();

  void replace(String location, {Object? extra});

  void replaceNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });
}
