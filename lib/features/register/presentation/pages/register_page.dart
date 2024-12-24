import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/button.dart';
import 'package:mesh_mobile/route_names.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_generateUsername);
  }

  void _generateUsername() {
    setState(() {
      String baseName = _nameController.text.trim().toLowerCase();
      // use uuid to generate random number to make username uniquername
      // final int randomNumber = Random().nextInt(1000);
      const int randomNumber = 1234;
      _username = baseName.isNotEmpty ? '@$baseName$randomNumber' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Username",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                "Adding ‘1434’ to make your username unique",
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  _username,
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
                onPressed: () {
                  context.go(Routes.home);
                },
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
