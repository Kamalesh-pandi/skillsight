class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? education;
  final String? department;
  final String? careerGoal;
  final List<String> manualSkills;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakUpdate;
  final int points;
  final DateTime? lastLearningTime;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.education,
    this.department,
    this.careerGoal,
    this.manualSkills = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStreakUpdate,
    this.points = 0,
    this.lastLearningTime,
  });

  int get effectiveStreak {
    if (lastStreakUpdate == null) return currentStreak;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastUpdate = DateTime(
      lastStreakUpdate!.year,
      lastStreakUpdate!.month,
      lastStreakUpdate!.day,
    );

    final difference = today.difference(lastUpdate).inDays;

    if (difference > 1) {
      return 0; // Streak broken because more than 1 day passed
    }

    return currentStreak;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'education': education,
      'department': department,
      'careerGoal': careerGoal,
      'manualSkills': manualSkills,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStreakUpdate': lastStreakUpdate?.toIso8601String(),
      'points': points,
      'lastLearningTime': lastLearningTime?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      education: map['education'],
      department: map['department'],
      careerGoal: map['careerGoal'],
      manualSkills: List<String>.from(map['manualSkills'] ?? []),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastStreakUpdate: map['lastStreakUpdate'] != null
          ? DateTime.parse(map['lastStreakUpdate'])
          : null,
      points: map['points'] ?? 0,
      lastLearningTime: map['lastLearningTime'] != null
          ? DateTime.parse(map['lastLearningTime'])
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? education,
    String? department,
    String? careerGoal,
    List<String>? manualSkills,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStreakUpdate,
    int? points,
    DateTime? lastLearningTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      education: education ?? this.education,
      department: department ?? this.department,
      careerGoal: careerGoal ?? this.careerGoal,
      manualSkills: manualSkills ?? this.manualSkills,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStreakUpdate: lastStreakUpdate ?? this.lastStreakUpdate,
      points: points ?? this.points,
      lastLearningTime: lastLearningTime ?? this.lastLearningTime,
    );
  }
}
