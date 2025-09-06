class DailyStats {
  final DateTime date;
  int completedTasks;
  int failedTasks;

  DailyStats({
    required this.date,
    this.completedTasks = 0,
    this.failedTasks = 0,
  });

  int get totalTasks => completedTasks + failedTasks;

  double get successRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  String get dateString {
    return '${date.day}/${date.month}/${date.year}';
  }

  DailyStats copyWith({
    DateTime? date,
    int? completedTasks,
    int? failedTasks,
  }) {
    return DailyStats(
      date: date ?? this.date,
      completedTasks: completedTasks ?? this.completedTasks,
      failedTasks: failedTasks ?? this.failedTasks,
    );
  }
}
