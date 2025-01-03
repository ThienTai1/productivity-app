import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:flutter_notes_app/controllers/theme_controller.dart';
import 'package:flutter_notes_app/widgets/app_drawer.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final _authController = Get.find<AuthController>();
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // Thêm button toggle theme
          IconButton(
            icon: Obx(() => Icon(themeController.isDarkMode.value
                    ? Icons.light_mode // Icon khi đang ở dark mode
                    : Icons.dark_mode // Icon khi đang ở light mode
                )),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Obx(() => Text(
                    'Welcome, ${_authController.currentUser.value?.username ?? ""}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              SizedBox(height: 40),
              _buildFeatureCard(
                icon: Icons.note,
                title: 'Notes',
                description: 'Manage your personal notes',
                onTap: () => Get.toNamed('/notes'),
              ),
              SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.event_note,
                title: 'Planner',
                description: 'Organize your schedule',
                onTap: () => Get.toNamed('/planner'),
              ),
              SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.task,
                title: 'Habits',
                description: 'Track your habits',
                onTap: () => Get.toNamed('/habits'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
