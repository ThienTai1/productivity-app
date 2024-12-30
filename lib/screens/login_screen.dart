import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart'; // Thêm đúng đường dẫn của lớp AuthController

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              onPressed: _login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final success = await _authController.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success) {
      Get.offAllNamed('/home'); // Thay đổi từ '/notes' thành '/home'
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }
  }
}
