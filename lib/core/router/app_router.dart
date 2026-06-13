import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import 'routes.dart';

/// App navigation. Splash owns the initial auth decision; login/home
/// pages react to [AuthCubit] state changes for the transitions between
/// the auth and main flows.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.game,
        builder: (context, state) => const GamePage(),
      ),
      GoRoute(
        path: Routes.dailyChallengeRun,
        builder: (context, state) => const GamePage(dailyChallenge: true),
      ),
    ],
  );
}
