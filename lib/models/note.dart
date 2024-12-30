class Note {
  int? id;
  int userId; // Thêm thuộc tính userId
  String title;
  String content;
  DateTime createdAt;

  Note({
    this.id,
    required this.userId, // userId là bắt buộc
    required this.title,
    required this.content,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Thêm userId vào map
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'], // Lấy userId từ map
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
