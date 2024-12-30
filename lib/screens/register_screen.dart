import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart'; // Lớp quản lý đăng nhập đăng ký

class RegisterScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    final success = await _authController.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (success) {
      Get.offAllNamed('/home'); // Thay đổi từ '/notes' thành '/home'
    } else {
      Get.snackbar('Error', 'Registration failed');
    }
  }
}
