import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return UserAccountsDrawerHeader(
              accountName: Text(user?.username ?? ''),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.username.isNotEmpty ?? false) 
                      ? user!.username[0].toUpperCase()
                      : '',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            );
          }),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Get.back();
              Get.offAllNamed('/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.note),
            title: Text('Notes'),
            onTap: () {
              Get.back();
              Get.toNamed('/notes');
            },
          ),
          ListTile(
            leading: Icon(Icons.event_note),
            title: Text('Planner'),
            onTap: () {
              Get.back();
              Get.toNamed('/planner');
            },
          ),
          ListTile(
            leading: Icon(Icons.expand_circle_down),
            title: Text('Habits'),
            onTap: () {
              Get.back();
              Get.toNamed('/habits');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}