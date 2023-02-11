import 'package:example/home/home_page.dart';
import 'package:example/navigation/routers.dart';
import 'package:example/seconds_screen/second_screen.dart';
import 'package:example/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: AppTheme.light(),
      //darkTheme: AppTheme.dark(),
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
      routes: [
        GoRoute(
          path: AppRoutes.second,
          builder: (BuildContext context, GoRouterState state) {
            return const SecondScreen();
          },
        ),
      ]
    ),

  ],
);
