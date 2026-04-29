import 'package:go_router/go_router.dart';
import 'package:maac_example/01_basic/basic_news_detail_page.dart';
import 'package:maac_example/01_basic/basic_news_page.dart';
import 'package:maac_example/02_di/di_news_detail_page.dart';
import 'package:maac_example/02_di/di_news_page.dart';
import 'package:maac_example/03_full/full_power_news_detail_page.dart';
import 'package:maac_example/03_full/full_power_news_page.dart';
import 'package:maac_example/navigation/routers.dart';
import 'package:maac_example/ui/landing_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
    GoRoute(path: AppRoutes.landing, builder: (context, state) => const LandingPage()),
    // Level 01: Basic
    GoRoute(path: AppRoutes.basic, builder: (context, state) => const BasicNewsPage()),
    GoRoute(
      path: AppRoutes.basicDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BasicNewsDetailPage(articleId: id);
      },
    ),
    // Level 02: DI
    GoRoute(path: AppRoutes.di, builder: (context, state) => const DiNewsPage()),
    GoRoute(
      path: AppRoutes.diDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return DiNewsDetailPage(articleId: id);
      },
    ),
    // Level 03: Full Power
    GoRoute(path: AppRoutes.full, builder: (context, state) => const FullPowerNewsPage()),
    GoRoute(
      path: AppRoutes.fullDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return FullPowerNewsDetailPage(articleId: id);
      },
    ),
  ],
);
