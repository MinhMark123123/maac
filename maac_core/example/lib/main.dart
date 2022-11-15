import 'package:example/global.dart';
import 'package:example/home/home_page.dart';
import 'package:example/navigation/app_navigate.dart';
import 'package:example/navigation/routers.dart';
import 'package:example/seconds_screen/second_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
final routeContextDelegateProvider = Provider<BuildContext?>((ref) {
  return _router.routerDelegate.navigatorKey.currentContext;
});
final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage();
      },
    ),
    GoRoute(
      path: AppRoutes.second,
      builder: (BuildContext context, GoRouterState state) {
        return const SecondScreen();
      },
    ),
  ],
);
