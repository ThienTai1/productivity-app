class User {
  int? id; // id có thể null
  String username;
  String email;
  String password;

  User({
    this.id, // id có thể là null
    required this.username,
    required this.email,
    required this.password,
  });

  // Chuyển đối tượng User thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,  // Thêm id vào Map
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // Tạo User từ Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],  // Đọc id từ Map (có thể là null)
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }
}
