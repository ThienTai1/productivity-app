import 'package:flutter_notes_app/services/database_service.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/models/user.dart';

class AuthController extends GetxController {
  final _db = DatabaseService.instance;
  final currentUser = Rxn<User>();

  Future<bool> login(String email, String password) async {
    final user = await _db.getUser(email, password);
    if (user != null) {
      currentUser.value = user;
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final user = User(
        username: username,
        email: email,
        password: password,
      );
      final createdUser = await _db.createUser(user);
      currentUser.value = createdUser;
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    currentUser.value = null;
  }
}