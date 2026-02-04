enum SkillCategory {
  programming,
  frameworks,
  tools,
  softSkills,
}

enum Proficiency {
  beginner,
  intermediate,
  advanced,
}

class SkillModel {
  final String name;
  final SkillCategory category;
  final Proficiency proficiency;

  SkillModel({
    required this.name,
    required this.category,
    required this.proficiency,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.name,
      'proficiency': proficiency.name,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      name: map['name'] ?? '',
      category: SkillCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => SkillCategory.programming,
      ),
      proficiency: Proficiency.values.firstWhere(
        (e) => e.name == map['proficiency'],
        orElse: () => Proficiency.beginner,
      ),
    );
  }
}
