import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/features/chat/presentation/bloc/chat_detail_bloc.dart';
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
          BlocProvider<ChatDetailBloc>(create: (context) => ChatDetailBloc())
        ], child: widget!);
      },
    );
  }
}
