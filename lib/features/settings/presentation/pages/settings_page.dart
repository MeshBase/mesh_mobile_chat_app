import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/button.dart';
import 'package:mesh_mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mesh_mobile/route_names.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(GetSettings());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
        bloc: context.read<SettingsBloc>(),
        listener: (context, state) {
          if (state is SettingsFormState && state.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Settings saved!"),
                duration: Duration(seconds: 1),
              ),
            );
            context.go(Routes.home);
          } else if (state is SettingsFormState && state.error.isNotEmpty) {
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error,
                    style: TextStyle(color: colorScheme.onError)),
                duration: const Duration(seconds: 2),
                backgroundColor: colorScheme.error,
              ),
            );
          }
          if (state is SettingsFormState) {
            _nameController.text = state.name;
            _userNameController.text =
                '${state.userNameBase}${state.userNameAppended}';
          }
        },
        child: Builder(builder: (context) {
          final bloc = context.watch<SettingsBloc>();
          final state = bloc.state;
          switch (state) {
            case SettingsInitial():
              bloc.add((GetSettings()));
              return const Center(
                child: CircularProgressIndicator(),
              );

            case SettingsLoading():
              return const Center(
                child: CircularProgressIndicator(),
              );

            case SettingsFormState():
              if (state.pending) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Settings"),
                  centerTitle: true,
                ),
                body: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name can\'t be empty';
                                } else if (value.length < 3) {
                                  return 'At least 3 characters required';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  bloc.add(ChangeName(name: value)),
                              decoration: InputDecoration(
                                hintText: "Your name",
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
                            TextField(
                              readOnly: true,
                              controller: _userNameController,
                              decoration: InputDecoration(
                                hintText: "Abebe_abcd_efgh",
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
                            const SizedBox(height: 50),
                            CustomButton(
                              text: "Update Profile",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  bloc.add(SubmitUpdatedSettings());
                                }
                              },
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      )),
                ),
              );
          }
        }));
  }
}
