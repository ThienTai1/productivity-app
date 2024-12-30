import 'package:flutter_notes_app/services/database_service.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/models/user.dart';


// class AuthController extends GetxController {
//   // Quản lý trạng thái người dùng
//   Rx<User?> currentUser = Rx<User?>(null);

//   // Hàm đăng ký người dùng
//   void register(User user) {
//     // Lưu thông tin người dùng vào cơ sở dữ liệu hoặc bộ nhớ tạm (ở đây giả sử đã lưu)
//     // Sau đó cập nhật currentUser
//     currentUser.value = user;
//     print("User Registered: ${user.username}");
//     Get.snackbar("Registration", "User ${user.username} registered successfully");
//   }

//   // Hàm đăng nhập người dùng
//   void login(String email, String password) {
//     // Kiểm tra thông tin đăng nhập
//     if (currentUser.value != null &&
//         currentUser.value!.email == email &&
//         currentUser.value!.password == password) {
//       print("Login Successful!");
//       Get.snackbar("Login", "Login Successful");

//       // Lấy userId và chuyển hướng đến trang home với userId
//       final userId = currentUser.value!.id;
//       if (userId != null) {
//         Get.toNamed('/home', arguments: userId); // Truyền userId vào arguments
//       }
//       else{
//         Get.snackbar("Login", "Invalid credentials");
//       }
//     } else {
//       print("Invalid credentials");
//       Get.snackbar("Login", "Invalid credentials");
//     }
//   }


//   // Hàm đăng xuất người dùng
//   void logout() {
//     currentUser.value = null;
//     print("Logged out");
//     Get.snackbar("Logout", "You have been logged out");
//     // Chuyển hướng về trang đăng nhập
//     Get.toNamed('/login');
//   }
// }

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