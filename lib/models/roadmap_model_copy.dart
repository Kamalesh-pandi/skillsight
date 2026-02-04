class RoadmapTask {
  final String title;
  final bool isCompleted;

  RoadmapTask({
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory RoadmapTask.fromMap(Map<String, dynamic> map) {
    return RoadmapTask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class RoadmapWeek {
  final int weekNumber;
  final List<RoadmapTask> tasks;

  RoadmapWeek({
    required this.weekNumber,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory RoadmapWeek.fromMap(Map<String, dynamic> map) {
    return RoadmapWeek(
      weekNumber: map['weekNumber'] ?? 0,
      tasks: (map['tasks'] as List? ?? [])
          .map((t) => RoadmapTask.fromMap(t))
          .toList(),
    );
  }
}

class RoadmapModel {
  final String id;
  final String userId;
  final String careerGoal;
  final List<RoadmapWeek> weeks;
  final DateTime createdAt;

  RoadmapModel({
    required this.id,
    required this.userId,
    required this.careerGoal,
    required this.weeks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'careerGoal': careerGoal,
      'weeks': weeks.map((w) => w.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RoadmapModel.fromMap(Map<String, dynamic> map) {
    return RoadmapModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      careerGoal: map['careerGoal'] ?? '',
      weeks: (map['weeks'] as List? ?? [])
          .map((w) => RoadmapWeek.fromMap(w))
          .toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
