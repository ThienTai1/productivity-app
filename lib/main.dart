import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:flutter_notes_app/controllers/habit_controller.dart';
import 'package:flutter_notes_app/controllers/note_controller.dart';
import 'package:flutter_notes_app/controllers/planner_controller.dart';
import 'package:flutter_notes_app/controllers/theme_controller.dart';
import 'package:flutter_notes_app/midlewares/route_guard.dart';
import 'package:flutter_notes_app/screens/habits/habit_view.dart';
import 'package:flutter_notes_app/screens/home_screen.dart';
import 'package:flutter_notes_app/screens/login_screen.dart';
import 'package:flutter_notes_app/screens/notes/note_view.dart';
import 'package:flutter_notes_app/screens/planners/planner_detail.dart';
import 'package:flutter_notes_app/screens/planners/planner_view.dart';
import 'package:flutter_notes_app/screens/register_screen.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final themeController = Get.find<ThemeController>();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productivity App',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(NoteController());
        Get.put(PlannerController());
        Get.put(HabitController());
      }),
      
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      themeMode: themeController.theme,
      
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          middlewares: [RouteGuard()],
        ),
        GetPage(
          name: '/notes',
          page: () => NotesScreen(),
          middlewares: [RouteGuard()],
        ),
        GetPage(
          name: '/planner',
          page: () => PlannerScreen(),
          middlewares: [RouteGuard()],
        ),
        GetPage(
          name: '/planner/detail',
          page: () => PlannerDetailScreen(planner: Get.arguments),
          middlewares: [RouteGuard()],
        ),
        GetPage(
          name: '/habits',
          page: () => HabitView(),
          middlewares: [RouteGuard()],
        ),
      ],
    ));
  }
}