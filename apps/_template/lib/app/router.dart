// Central route table + the auth gate. Screen widgets stay free of navigation
// wiring so they remain unit-testable. See docs/starter-template/navigation.md.

import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/items/presentation/item_detail_screen.dart';
import '../features/items/presentation/item_form_screen.dart';
import '../features/items/presentation/items_list_screen.dart';

abstract final class Routes {
  static const login = '/login';
  static const items = '/';
  static const itemNew = '/items/new';
  static String itemDetail(String id) => '/items/$id';
  static String itemEdit(String id) => '/items/$id/edit';
}

Page<void> _page(
  Widget child,
  GoRouterState state, {
  AmdsTransition transition = AmdsTransition.sharedAxisX,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AmdsMotion.moderate,
      reverseTransitionDuration: AmdsMotion.base,
      transitionsBuilder: AmdsPageTransitions.resolve(transition),
    );

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild the redirect whenever auth state changes.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: Routes.items,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) return null; // wait for restore()
      final signedIn = auth.valueOrNull != null;
      final atLogin = state.matchedLocation == Routes.login;
      if (!signedIn) return atLogin ? null : Routes.login;
      if (atLogin) return Routes.items;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) =>
            _page(const LoginScreen(), state, transition: AmdsTransition.fade),
      ),
      GoRoute(
        path: Routes.items,
        pageBuilder: (context, state) => _page(
          const ItemsListScreen(),
          state,
          transition: AmdsTransition.fadeThrough,
        ),
        routes: [
          GoRoute(
            path: 'items/new',
            pageBuilder: (context, state) => _page(
              const ItemFormScreen(),
              state,
              transition: AmdsTransition.sharedAxisY,
            ),
          ),
          GoRoute(
            path: 'items/:id',
            pageBuilder: (context, state) => _page(
              ItemDetailScreen(id: state.pathParameters['id']!),
              state,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => _page(
                  ItemFormScreen(id: state.pathParameters['id']),
                  state,
                  transition: AmdsTransition.sharedAxisY,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
