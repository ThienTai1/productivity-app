import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Kiểm tra nếu người dùng chưa đăng nhập
    final isLoggedIn = Get.find<AuthController>().currentUser.value != null;
    if (!isLoggedIn) {
      // Nếu không đăng nhập, chuyển hướng đến trang đăng nhập
      return RouteSettings(name: '/login');
    }
    // Nếu đã đăng nhập, không chuyển hướng
    return null;
  }
}
