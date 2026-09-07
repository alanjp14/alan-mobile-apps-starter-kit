// Central route table. Add routes here; keep screen widgets free of navigation
// wiring so they stay unit-testable. See docs/starter-template/navigation.md.

import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/items/presentation/item_detail_screen.dart';
import '../features/items/presentation/items_list_screen.dart';

abstract final class Routes {
  static const items = '/';
  static String itemDetail(String id) => '/items/$id';
}

/// A go_router page that uses an [AmdsTransition]. Default is shared-axis-X;
/// pass `AmdsTransition.sharedAxisY` for routes that "come up".
Page<void> _amdsPage(
  Widget child, {
  AmdsTransition transition = AmdsTransition.sharedAxisX,
  LocalKey? key,
}) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: AmdsMotion.moderate,
      reverseTransitionDuration: AmdsMotion.base,
      transitionsBuilder: AmdsPageTransitions.resolve(transition),
    );

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.items,
    routes: [
      GoRoute(
        path: Routes.items,
        name: 'items',
        pageBuilder: (context, state) => _amdsPage(
          const ItemsListScreen(),
          key: state.pageKey,
          transition: AmdsTransition.fadeThrough,
        ),
        routes: [
          GoRoute(
            path: 'items/:id',
            name: 'itemDetail',
            pageBuilder: (context, state) => _amdsPage(
              ItemDetailScreen(id: state.pathParameters['id']!),
              key: state.pageKey,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
