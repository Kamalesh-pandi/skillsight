class ProjectSuggestionModel {
  final String projectIdea;
  final List<String> techStack;
  final List<String> buildPlan;
  final List<String> githubStructure;

  ProjectSuggestionModel({
    required this.projectIdea,
    required this.techStack,
    required this.buildPlan,
    required this.githubStructure,
  });

  factory ProjectSuggestionModel.fromMap(Map<String, dynamic> map) {
    return ProjectSuggestionModel(
      projectIdea: map['projectIdea']?.toString() ?? '',
      techStack: List<String>.from(map['techStack'] ?? []),
      buildPlan: List<String>.from(map['buildPlan'] ?? []),
      githubStructure: List<String>.from(map['githubStructure'] ?? []),
    );
  }
}
