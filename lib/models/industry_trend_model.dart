class IndustryTrendModel {
  final double matchScore;
  final List<SkillDemand> topSkills;
  final List<String> hotSkills;
  final List<String> missingSkills;
  final String lastUpdated;

  IndustryTrendModel({
    required this.matchScore,
    required this.topSkills,
    required this.hotSkills,
    required this.missingSkills,
    required this.lastUpdated,
  });

  factory IndustryTrendModel.fromMap(Map<String, dynamic> map) {
    return IndustryTrendModel(
      matchScore: (map['matchScore'] ?? 0).toDouble(),
      topSkills: (map['topSkills'] as List?)
              ?.map((x) => SkillDemand.fromMap(x))
              .toList() ??
          [],
      hotSkills: List<String>.from(map['hotSkills'] ?? []),
      missingSkills: List<String>.from(map['missingSkills'] ?? []),
      lastUpdated: map['lastUpdated'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class SkillDemand {
  final String name;
  final int demandPercentage;
  final String level; // Beginner, Intermediate, Advanced

  SkillDemand({
    required this.name,
    required this.demandPercentage,
    required this.level,
  });

  factory SkillDemand.fromMap(Map<String, dynamic> map) {
    return SkillDemand(
      name: map['name'] ?? '',
      demandPercentage: map['demandPercentage'] ?? 0,
      level: map['level'] ?? 'Beginner',
    );
  }
}
