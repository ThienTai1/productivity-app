class Habit {
  int? id;
  int userId;
  String title;
  String description;
  int targetDays;
  DateTime startDate;
  DateTime? endDate;
  bool isCompleted;
  List<DateTime> completedDates;  // Để theo dõi các ngày đã hoàn thành

  Habit({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetDays,
    required this.startDate,
    this.endDate,
    this.isCompleted = false,
    List<DateTime>? completedDates,
  }) : this.completedDates = completedDates ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'completedDates': completedDates.map((date) => date.toIso8601String()).join(','),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    List<DateTime> parseCompletedDates(String? datesStr) {
      if (datesStr == null || datesStr.isEmpty) return [];
      return datesStr
          .split(',')
          .map((dateStr) => DateTime.parse(dateStr))
          .toList();
    }

    return Habit(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      targetDays: map['targetDays'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isCompleted: map['isCompleted'] == 1,
      completedDates: parseCompletedDates(map['completedDates']),
    );
  }
}