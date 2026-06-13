import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/awards_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/challenges/presentation/daily_challenge_screen.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/leaderboards/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_page.dart';
import 'routes.dart';

/// App navigation. Splash owns the initial auth decision; login/home
/// pages react to [AuthCubit] state changes for the transitions between
/// the auth and main flows. The meta screens read the per-account session
/// through SessionHolder and so only mount after sign-in.
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
      GoRoute(
        path: Routes.dailyChallenge,
        builder: (context, state) => const DailyChallengeScreen(),
      ),
      GoRoute(
        path: Routes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: Routes.awards,
        builder: (context, state) => const AwardsScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
