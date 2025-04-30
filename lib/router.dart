import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';
import 'package:mesh_mobile/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:mesh_mobile/features/chat/presentation/pages/chat_list_page.dart';
import 'package:mesh_mobile/features/nearby_users/presentation/pages/nearby_users_page.dart';
import 'package:mesh_mobile/features/register/presentation/pages/register_page.dart';
import 'package:mesh_mobile/features/search/presentation/pages/search_users_page.dart';
import 'package:mesh_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:mesh_mobile/home/presentation/pages/home_page.dart';
import 'package:mesh_mobile/route_names.dart';
import 'package:mesh_mobile/route_observer.dart';

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: Routes.init,
      builder: (context, state) {
        return RegisterPage();
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return const Home();
      },
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) {
        return RegisterPage();
      },
    ),
    GoRoute(
      path: Routes.nearby,
      builder: (context, state) {
        return const NearbyUsersPage();
      },
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) {
        return const SearchUsersPage();
      },
    ),
    GoRoute(
      path: Routes.chatList,
      builder: (context, state) {
        return const ChatListPage();
      },
    ),
    GoRoute(
      path: Routes.chat,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null) {
          return ChatDetailPage(
            userInfoModel: extra as UserInfoModel,
          );
        }

        return const Scaffold(
          body: Center(child: Text('Invalid user data')),
        );
      },
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) {
        return const SettingsPage();
      },
    )
  ],
);
