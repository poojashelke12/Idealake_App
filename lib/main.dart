import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/announcements/view_model/announcements_bloc.dart';
import 'features/auth/view_model/auth_bloc.dart';
import 'features/documents/view_model/documents_bloc.dart';
import 'features/home/view_model/home_bloc.dart';
import 'features/news/view_model/news_bloc.dart';
import 'features/policies/view_model/policies_bloc.dart';
import 'features/splash/view_model/splash_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Dependency Injection
  await setupServiceLocator();

  runApp(const IdealakeApp());
}

/// Root Application Widget configured with BLoC & MVVM Architecture
class IdealakeApp extends StatelessWidget {
  const IdealakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(create: (_) => locator<SplashBloc>()),
        BlocProvider<HomeBloc>(create: (_) => locator<HomeBloc>()),
        BlocProvider<AnnouncementsBloc>(
          create: (_) => locator<AnnouncementsBloc>(),
        ),
        BlocProvider<NewsBloc>(create: (_) => locator<NewsBloc>()),
        BlocProvider<PoliciesBloc>(create: (_) => locator<PoliciesBloc>()),
        BlocProvider<DocumentsBloc>(create: (_) => locator<DocumentsBloc>()),
        BlocProvider<AuthBloc>(create: (_) => locator<AuthBloc>()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
