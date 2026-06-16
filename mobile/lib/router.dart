import 'package:go_router/go_router.dart';

import 'features/car_selector/ui/make_list_page.dart';
import 'features/car_selector/ui/model_list_page.dart';
import 'features/car_selector/ui/generation_list_page.dart';
import 'features/car_selector/ui/confirmation_page.dart';
import 'features/home/home_page.dart';

/// Application router with 5 named routes for the car selector flow.
///
/// Routes that require an int `extra` (makeId / modelId) perform a null-guard:
/// if extra is null (e.g., after hot-restart) they redirect to '/selector/make'
/// to avoid a runtime cast error (Pitfall 3).
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/selector/make',
      builder: (context, state) => const MakeListPage(),
    ),
    GoRoute(
      path: '/selector/model',
      redirect: (context, state) {
        if (state.extra == null) return '/selector/make';
        return null;
      },
      builder: (context, state) {
        final makeId = state.extra as int;
        return ModelListPage(makeId: makeId);
      },
    ),
    GoRoute(
      path: '/selector/generation',
      redirect: (context, state) {
        if (state.extra == null) return '/selector/make';
        return null;
      },
      builder: (context, state) {
        final modelId = state.extra as int;
        return GenerationListPage(modelId: modelId);
      },
    ),
    GoRoute(
      path: '/selector/confirm',
      builder: (context, state) => const ConfirmationPage(),
    ),
  ],
);
