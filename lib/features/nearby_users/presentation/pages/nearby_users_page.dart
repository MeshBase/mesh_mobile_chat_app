import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/list_item.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';
import 'package:mesh_mobile/features/nearby_users/presentation/bloc/nearby_users_bloc.dart';
import 'package:mesh_mobile/route_names.dart';
import 'package:mesh_mobile/route_observer.dart';

class NearbyUsersPage extends StatefulWidget {
  const NearbyUsersPage({super.key});

  @override
  State<NearbyUsersPage> createState() => _NearbyUsersPageState();
}

class _NearbyUsersPageState extends State<NearbyUsersPage> with RouteAware {
  late final NearbyUsersBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<NearbyUsersBloc>();
    bloc.add(LoadNearbyUsers());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    bloc.add(LoadNearbyUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyUsersBloc, NearbyUsersState>(
        builder: (context, state) {
      switch (state) {
        case NearbyUsersInitial() || NearbyUsersLoading():
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                Text('${state.runtimeType}'),
                const SizedBox(height: 8),
              ],
            ),
          );
        case NearbyUsersLoaded():
          final users = state.nearbyUsers;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserListItem(
                        name: user.name,
                        statusMessage:
                            user.lastMessage ?? "Start a Conversation",
                        isOnline: user.isOnline,
                        initial: user.initial,
                        notificationCount:
                            user.unreadCount > 0 ? user.unreadCount : null,
                        onPressed: () {
                          // when clicked create chat?
                          final data = UserInfoModel(
                            chatId: user.userId,
                            name: user.name,
                            userId: user.userId,
                            userName: user.username,
                          );
                          context.push(Routes.chat, extra: data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        default:
          return Center(child: Text('Unknown state $state'));
      }
    });
  }
}
