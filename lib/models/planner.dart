class Planner {
  int? id;
  int userId;
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  Planner({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Planner.fromMap(Map<String, dynamic> map) {
    return Planner(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1,
    );
  }
}