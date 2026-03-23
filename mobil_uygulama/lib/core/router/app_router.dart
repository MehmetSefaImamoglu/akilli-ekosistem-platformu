import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/anomaly/presentation/pages/anomaly_list_page.dart';

// ──────────────────────────────────────────────────────────────
// GoRouter redirect mantığı:
//   • Oturum açılmamışsa → /login
//   • Oturum açılmışsa ve auth ekranındaysa → /dashboard
// ──────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  // Auth state değiştiğinde router yeniden değerlendir
  final authNotifier = _AuthChangeNotifier(ref);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider).valueOrNull;
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Henüz yüklenmediyse bekle
      if (authState == null || authState is AuthStateInitial) return null;

      // Giriş yapılmamış → login'e yönlendir
      if (!isAuthenticated && !isOnAuthPage) return '/login';

      // Giriş yapılmış ama auth sayfasındaysa → dashboard'a yönlendir
      if (isAuthenticated && isOnAuthPage) return '/dashboard';

      return null; // Yönlendirme yok
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/anomalies',
        name: 'anomalies',
        builder: (context, state) => const AnomalyListPage(),
      ),
    ],
  );

  return router;
});

// ──────────────────────────────────────────────────────────────
// GoRouter'ın Riverpod auth değişikliklerine tepki vermesi için
// ChangeNotifier köprüsü
// ──────────────────────────────────────────────────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}
