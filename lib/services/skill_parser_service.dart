import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/skill_model.dart';
import 'dart:io';
import 'ai_service.dart';

class SkillParserService {
  final AIService _aiService = AIService();

  Future<String> extractTextFromPdf(File file) async {
    final PdfDocument document =
        PdfDocument(inputBytes: await file.readAsBytes());
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<Map<String, dynamic>> parseSkills(String text) async {
    final aiData = await _aiService.extractSkills(text);
    final List<Map<String, dynamic>> skillsData = aiData['skills'];
    final String suggestedGoal = aiData['suggestedGoal'];

    final skills = skillsData.map((data) {
      // Map string level to Proficiency enum
      Proficiency proficiency = Proficiency.beginner;
      String level = data['level']?.toString().toLowerCase() ?? '';
      if (level.contains('advanced')) {
        proficiency = Proficiency.advanced;
      } else if (level.contains('intermediate')) {
        proficiency = Proficiency.intermediate;
      }

      return SkillModel(
        name: data['name'] ?? 'Unknown Skill',
        category: SkillCategory.programming,
        proficiency: proficiency,
      );
    }).toList();

    return {
      'skills': skills,
      'suggestedGoal': suggestedGoal,
      'readiness': aiData['readiness'] ?? [],
    };
  }

  double calculateReadinessScore(
      List<String> userSkills, List<String> requiredSkills) {
    if (requiredSkills.isEmpty) return 0.0;
    int matched = 0;
    for (var skill in requiredSkills) {
      if (userSkills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
        matched++;
      }
    }
    return matched / requiredSkills.length;
  }
}
