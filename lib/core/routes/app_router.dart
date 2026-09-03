import 'package:flutter/material.dart';

import '../../features/auth/views/login_screen.dart';
import '../../features/news/models/news_model.dart';
import '../../features/news/views/news_detail_screen.dart';
import '../../features/policies/models/policy_model.dart';
import '../../features/policies/views/policy_viewer_screen.dart';
import '../../features/shell/views/main_nav_screen.dart';
import '../../features/splash/views/splash_screen.dart';
import 'app_routes.dart';

/// Centralized Application Route Management
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.mainNav:
        return MaterialPageRoute(
          builder: (_) => const MainNavScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.newsDetail:
        final news = settings.arguments as NewsModel;
        return MaterialPageRoute(
          builder: (_) => NewsDetailScreen(news: news),
          settings: settings,
        );

      case AppRoutes.policyViewer:
        final policy = settings.arguments as PolicyModel;
        return MaterialPageRoute(
          builder: (_) => PolicyViewerScreen(policy: policy),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const MainNavScreen(),
          settings: settings,
        );
    }
  }
}
