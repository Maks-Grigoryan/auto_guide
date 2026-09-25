import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/auth/auth_repository.dart';
import 'features/ai_chat/ai_chat_page.dart';
import 'features/auth/ui/auth_page.dart';
import 'features/car_selector/ui/make_list_page.dart';
import 'features/car_selector/ui/model_list_page.dart';
import 'features/car_selector/ui/generation_list_page.dart';
import 'features/car_selector/ui/confirmation_page.dart';
import 'features/home/home_page.dart';
import 'features/hub/hub_page.dart';
import 'features/parts_results/parts_results_page.dart';
import 'features/repair_search/service_categories_page.dart';
import 'features/repair_search/repair_results_page.dart';
import 'features/vendor_detail/vendor_detail_page.dart';

/// Application router with 5 named routes for the car selector flow.
///
/// Routes that require an int `extra` (makeId / modelId) perform a null-guard:
/// if extra is null (e.g., after hot-restart) they redirect to '/selector/make'
/// to avoid a runtime cast error (Pitfall 3).
/// True once the user has confirmed a car.
///
/// Read straight from Hive rather than through the provider because the router
/// is built outside the ProviderScope. The box is opened in main() before
/// runApp, so this is safe and synchronous. Mirrors the box and key used by
/// SelectedCarNotifier — change them together.
bool _hasSelectedCar() =>
    Hive.box('selectedCar').get('current') != null;

/// True once someone has signed in.
///
/// Read from Hive for the same reason as the car above: redirect is
/// synchronous, and the access token lives in secure storage behind an async
/// API. Only the role is cached here — never the token itself.
bool _isSignedIn() => hasStoredSession(Hive.box('appSettings'));

/// Routes that cannot do anything useful without a car.
///
/// The car is a property of the parts/repair search — every query is filtered
/// by make, model and generation — not of the app as a whole. Sections that do
/// not search a catalogue (the main screen, and the roadside ones planned next)
/// must not be held behind it.
const _carRequiredPrefixes = ['/search', '/results', '/repair'];

bool _needsCar(String location) =>
    _carRequiredPrefixes.any(location.startsWith);

final appRouter = GoRouter(
  initialLocation: '/',

  /// Two gates, in order: an account, then a car — and the car only for the
  /// search section.
  ///
  /// The car guard is also what removes the «Выбрать авто» button: HomePage
  /// only renders it when no car is set, and past this guard that state is
  /// unreachable — the car is shown as a tappable CarChip instead, which is how
  /// it gets changed.
  redirect: (context, state) {
    final onAuth = state.matchedLocation == '/auth';

    // Signing in comes first: the car selector already talks to the API, and
    // every screen past it assumes there is an account behind the session.
    if (!_isSignedIn()) return onAuth ? null : '/auth';

    // Signed in — there is nothing left to do on the sign-in screen. Land on
    // the main screen whether or not a car has ever been chosen: the menu is
    // readable without one.
    if (onAuth) return '/';

    final inSelector = state.matchedLocation.startsWith('/selector');
    if (!_hasSelectedCar() && !inSelector && _needsCar(state.matchedLocation)) {
      return '/selector/make';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HubPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        // The hub passes which section to open: 0 = parts, 1 = repair.
        // Anything else (deep link, confirmation page) lands on parts.
        final extra = state.extra;
        final initialIndex = extra is int && extra == 1 ? 1 : 0;
        return HomePage(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    // Outside _carRequiredPrefixes on purpose: the assistant is where someone
    // goes when they cannot name the part, let alone the generation of the car
    // it belongs to. Asking for the car at the door would gate the one screen
    // built for people who do not have those answers yet.
    GoRoute(
      path: '/ai-chat',
      builder: (context, state) => const AiChatPage(),
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
    GoRoute(
      path: '/results/parts',
      builder: (context, state) => const PartsResultsPage(),
    ),
    GoRoute(
      path: '/repair/categories',
      builder: (context, state) => const ServiceCategoriesPage(),
    ),
    GoRoute(
      path: '/results/repair',
      builder: (context, state) {
        final categoryName = state.extra as String?;
        return RepairResultsPage(categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/vendor/:id',
      builder: (context, state) => VendorDetailPage(
        vendorId: state.pathParameters['id']!,
      ),
    ),
  ],
);
