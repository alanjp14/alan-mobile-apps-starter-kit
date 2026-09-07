// Central route table. Add routes here; keep screen widgets free of navigation
// wiring so they stay unit-testable. See docs/starter-template/navigation.md.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/items/presentation/item_detail_screen.dart';
import '../features/items/presentation/items_list_screen.dart';

abstract final class Routes {
  static const items = '/';
  static String itemDetail(String id) => '/items/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.items,
    routes: [
      GoRoute(
        path: Routes.items,
        name: 'items',
        builder: (context, state) => const ItemsListScreen(),
        routes: [
          GoRoute(
            path: 'items/:id',
            name: 'itemDetail',
            builder: (context, state) =>
                ItemDetailScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
});
