class Task {
  final String id;
  final String title;
  final int timeInMinutes;
  final DateTime createdAt;
  bool isCompleted;
  int remainingSeconds;

  Task({
    required this.id,
    required this.title,
    required this.timeInMinutes,
    required this.createdAt,
    this.isCompleted = false,
  }) : remainingSeconds = timeInMinutes * 60;

  Task copyWith({
    String? id,
    String? title,
    int? timeInMinutes,
    DateTime? createdAt,
    bool? isCompleted,
    int? remainingSeconds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      timeInMinutes: timeInMinutes ?? this.timeInMinutes,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    )..remainingSeconds = remainingSeconds ?? this.remainingSeconds;
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progressPercentage {
    final totalSeconds = timeInMinutes * 60;
    return remainingSeconds / totalSeconds;
  }
}