class RoadmapTask {
  final String title;
  final bool isCompleted;
  final String? bestResources;
  final String? youtubeQuery;
  final List<Map<String, dynamic>>? quizQuestions;
  final List<Map<String, dynamic>>? interviewQuestions;
  final int? quizScore;
  final DateTime? lastTestedAt;

  RoadmapTask({
    required this.title,
    this.isCompleted = false,
    this.bestResources,
    this.youtubeQuery,
    this.quizQuestions,
    this.interviewQuestions,
    this.quizScore,
    this.lastTestedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'bestResources': bestResources,
      'youtubeQuery': youtubeQuery,
      'quizQuestions': quizQuestions,
      'interviewQuestions': interviewQuestions,
      'quizScore': quizScore,
      'lastTestedAt': lastTestedAt?.toIso8601String(),
    };
  }

  factory RoadmapTask.fromMap(Map<String, dynamic> map) {
    return RoadmapTask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      bestResources: map['bestResources'],
      youtubeQuery: map['youtubeQuery'],
      quizQuestions: map['quizQuestions'] != null
          ? List<Map<String, dynamic>>.from(map['quizQuestions'])
          : null,
      interviewQuestions: map['interviewQuestions'] != null
          ? List<Map<String, dynamic>>.from(map['interviewQuestions'])
          : null,
      quizScore: map['quizScore'],
      lastTestedAt: map['lastTestedAt'] != null
          ? DateTime.parse(map['lastTestedAt'])
          : null,
    );
  }

  RoadmapTask copyWith({
    String? title,
    bool? isCompleted,
    String? bestResources,
    String? youtubeQuery,
    List<Map<String, dynamic>>? quizQuestions,
    List<Map<String, dynamic>>? interviewQuestions,
    int? quizScore,
    DateTime? lastTestedAt,
  }) {
    return RoadmapTask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      bestResources: bestResources ?? this.bestResources,
      youtubeQuery: youtubeQuery ?? this.youtubeQuery,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      interviewQuestions: interviewQuestions ?? this.interviewQuestions,
      quizScore: quizScore ?? this.quizScore,
      lastTestedAt: lastTestedAt ?? this.lastTestedAt,
    );
  }
}

class RoadmapWeek {
  final int weekNumber;
  final String focus;
  final List<RoadmapTask> tasks;

  RoadmapWeek({
    required this.weekNumber,
    required this.focus,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'focus': focus,
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory RoadmapWeek.fromMap(Map<String, dynamic> map) {
    return RoadmapWeek(
      weekNumber: map['weekNumber'] ?? 0,
      focus: map['focus'] ?? '',
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
