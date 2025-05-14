import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/button.dart';
import 'package:mesh_mobile/features/register/presentation/bloc/register_bloc.dart';
import 'package:mesh_mobile/route_names.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener(
            bloc: context.read<RegisterBloc>(),
            listener: (context, state) {
              if (state is Registered && !state.wasAlreadyRegistered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Registration successful!"),
                    duration: Duration(seconds: 2),
                  ),
                );
                context.go(Routes.home);
              } else if (state is FormActiveRegistration &&
                  state.error.isNotEmpty) {
                final colorScheme = Theme.of(context).colorScheme;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error,
                        style: TextStyle(color: colorScheme.onError)),
                    duration: const Duration(seconds: 2),
                    backgroundColor: colorScheme.error,
                  ),
                );
              } else if (state is Registered && state.wasAlreadyRegistered) {
                context.go(Routes.home);
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Builder(builder: (context) {
                  final bloc = context.watch<RegisterBloc>();
                  final state = bloc.state;

                  switch (state) {
                    case RegisterInitial():
                      bloc.add((GetIsRegistered()));
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case RegisterLoading():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case Registered():
                      return Container();

                    case FormActiveRegistration():
                      if (state.pending) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Hi, Welcome! 👋",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                "Name",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: state.name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name can\'t be empty';
                                  } else if (value.length < 3) {
                                    return 'At least 3 characters required';
                                  }
                                  return null;
                                },
                                onChanged: (String name) {
                                  bloc.add(ChangeName(name: name));
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter your name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Username",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              if (state.name.isNotEmpty)
                                Text(
                                  "Adding '${state.userNameAppended}' to make your username unique",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 16.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors.grey[200],
                                ),
                                child: Text(
                                  state.name.isNotEmpty
                                      ? state.userNameBase +
                                          state.userNameAppended
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              CustomButton(
                                text: "Register",
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    bloc.add(SubmitRegistration());
                                  }
                                },
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ));
                  }
                }))),
      ),
    );
  }
}
