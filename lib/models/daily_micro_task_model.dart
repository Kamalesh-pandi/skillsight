enum DailyMicroTaskStatus {
  pending,
  inProgress,
  done,
  skipped,
}

class DailyMicroTask {
  final String id;
  final String title;
  final String description;
  final String skillTag;
  final int durationMinutes;
  final DailyMicroTaskStatus status;
  final DateTime date;

  const DailyMicroTask({
    required this.id,
    required this.title,
    required this.description,
    required this.skillTag,
    required this.durationMinutes,
    required this.status,
    required this.date,
  });

  DailyMicroTask copyWith({
    String? id,
    String? title,
    String? description,
    String? skillTag,
    int? durationMinutes,
    DailyMicroTaskStatus? status,
    DateTime? date,
  }) {
    return DailyMicroTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      skillTag: skillTag ?? this.skillTag,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'skillTag': skillTag,
      'durationMinutes': durationMinutes,
      'status': status.name,
      'date': date.toIso8601String(),
    };
  }

  factory DailyMicroTask.fromMap(Map<String, dynamic> map) {
    return DailyMicroTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      skillTag: map['skillTag'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      status: DailyMicroTaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => DailyMicroTaskStatus.pending,
      ),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
