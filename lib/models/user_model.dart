class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? education;
  final String? department;
  final String? careerGoal;
  final List<String> manualSkills;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.education,
    this.department,
    this.careerGoal,
    this.manualSkills = const [],
  });

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
    );
  }
}
