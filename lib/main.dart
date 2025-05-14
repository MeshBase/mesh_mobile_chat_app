import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/presentation/bloc/chat_detail_bloc.dart';
import 'package:mesh_mobile/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:mesh_mobile/features/nearby_users/data/nearby_repository.dart';
import 'package:mesh_mobile/features/nearby_users/presentation/bloc/nearby_users_bloc.dart';
import 'package:mesh_mobile/features/register/presentation/bloc/register_bloc.dart';
import 'package:mesh_mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mesh_mobile/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MeshApp());
}

class MeshApp extends StatelessWidget {
  const MeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mesh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      routerConfig: router,
      builder: (context, widget) {
        return MultiBlocProvider(providers: [
          BlocProvider<ChatDetailBloc>(create: (context) => ChatDetailBloc()),
          BlocProvider<ChatListBloc>(
              create: (context) =>
                  ChatListBloc(chatRepository: ChatRepository())),
          BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),

          BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
          BlocProvider<NearbyUsersBloc>(create: (context) => NearbyUsersBloc(
                    nearbyRepository: NearbyRepository())
          ),
        ], child: widget!);
      },
    );
  }
}
