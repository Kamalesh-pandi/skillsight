class PortfolioAnalysisModel {
  final int codeQualityScore;
  final int projectComplexityScore;
  final int jobRelevanceScore;
  final List<String> suggestions;
  final String analysisSummary;

  PortfolioAnalysisModel({
    required this.codeQualityScore,
    required this.projectComplexityScore,
    required this.jobRelevanceScore,
    required this.suggestions,
    required this.analysisSummary,
  });

  factory PortfolioAnalysisModel.fromMap(Map<String, dynamic> map) {
    return PortfolioAnalysisModel(
      codeQualityScore: map['codeQualityScore'] as int? ?? 0,
      projectComplexityScore: map['projectComplexityScore'] as int? ?? 0,
      jobRelevanceScore: map['jobRelevanceScore'] as int? ?? 0,
      suggestions: List<String>.from(map['suggestions'] ?? []),
      analysisSummary: map['analysisSummary'] as String? ?? '',
    );
  }
}
