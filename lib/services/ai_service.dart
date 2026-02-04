import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>> extractSkills(String resumeText) async {
    final prompt = '''
    Extract all technical and soft skills from the following resume text.
    Classify skill level as "Beginner", "Intermediate", or "Advanced".
    Also, suggest a single most likely career goal (e.g. "Flutter Developer", "Frontend Engineer") based on the work experience and skills.
    
    Return response in JSON format like this: 
    {
      "skills": [{"name": "Flutter", "level": "Beginner"}, ...],
      "suggestedGoal": "Flutter Developer",
      "readiness": [
        {"company": "Zoho", "score": 75},
        {"company": "Google", "score": 60},
        ... (exactly 15 most relevant companies)
      ]
    }

    Resume Text:
    $resumeText
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      final data = jsonDecode(text);
      return {
        'skills': List<Map<String, dynamic>>.from(data['skills']),
        'suggestedGoal': data['suggestedGoal']?.toString() ?? '',
        'readiness': List<Map<String, dynamic>>.from(data['readiness'] ?? []),
      };
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('quota')) {
        throw Exception(
            'Firebase AI Quota Exceeded: Please check your Firebase billing or project limits.');
      } else if (errorStr.contains('firebaseml.googleapis.com')) {
        throw Exception(
            'Firebase ML API Disabled: Please enable the API at https://console.developers.google.com/apis/api/firebaseml.googleapis.com/overview?project=983718372502');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> generateRoadmap(
      String careerGoal, List<String> missingSkills) async {
    final prompt = '''
      You are an expert career coach and technical mentor.
      Target Career Goal: $careerGoal
      Missing Skills: ${missingSkills.join(', ')}

      Generate a comprehensive and realistic learning roadmap to master these missing skills.
      Important Rules:
      1. The duration should be flexible based on the complexity of skills (minimum 4 weeks, maximum 12 weeks).
      2. Provide a week-by-week breakdown.
      3. For each week, provide a focus and a list of 3-5 specific, actionable tasks/topics.
      4. Return the data ONLY as a JSON object with a key "roadmap" containing a list of weeks.

      JSON Structure:
      {
        "roadmap": [
          {
            "week": 1,
            "focus": "Topic name",
            "tasks": ["Task 1", "Task 2", "Task 3"]
          },
          ...
        ]
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      final data = jsonDecode(text);
      return List<Map<String, dynamic>>.from(data['roadmap']);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('quota')) {
        throw Exception(
            'Firebase AI Quota Exceeded: Please check your Firebase billing or project limits.');
      } else if (errorStr.contains('firebaseml.googleapis.com')) {
        throw Exception(
            'Firebase ML API Disabled: Please enable the API at https://console.developers.google.com/apis/api/firebaseml.googleapis.com/overview?project=983718372502');
      }
      rethrow;
    }
  }

  Future<Map<String, String>> fetchTaskResources(
      String topic, String careerGoal) async {
    final prompt = '''
      You are a technical mentor. Provide the best learning resources for the following topic:
      Topic: $topic
      Target Goal: $careerGoal

      Return ONLY a JSON object with:
      1. "bestResources": A string with 2-3 high-quality website or documentation links. Include the name and the full URL.
      2. "youtubeQuery": A specific, optimized YouTube search query to find the best tutorials for this topic (e.g., "Advanced Flutter State Management Tutorial").

      JSON Format:
      {
        "bestResources": "Resource name: https://... \\nResource name: https://...",
        "youtubeQuery": "Optimized Search Query Here"
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response');

      final data = jsonDecode(text);
      return {
        'bestResources': data['bestResources'] ?? 'No resources found.',
        'youtubeQuery': data['youtubeQuery'] ?? '',
      };
    } catch (e) {
      print('DEBUG: Gemini Resource Error: $e');
      return {
        'bestResources': 'Failed to load resources.',
        'youtubeQuery': '',
      };
    }
  }

  Future<List<Map<String, dynamic>>> generateQuiz(
      String topic, String careerGoal,
      {bool isInterviewMode = false}) async {
    final String contextPrompt = isInterviewMode
        ? 'You are a Senior Technical Interviewer at a top tier tech company. Generate a TOUGH, CONCEPTUAL mock interview quiz using 10 Multiple Choice Questions (MCQs).'
        : 'You are a technical mentor. Generate a quiz of 10 Multiple Choice Questions (MCQs).';

    final String questionTypePrompt = isInterviewMode
        ? 'Questions should focus on "Why", "How it works under the hood", edge cases, and architectural trade-offs. Avoid simple syntax questions.'
        : 'Questions should test understanding of concepts and practical usage.';

    final prompt = '''
      $contextPrompt
      Topic: $topic
      Target Career Goal: $careerGoal

      $questionTypePrompt

      Constraints for speed:
      1. Keep questions and options concise (max 15 words each).
      2. Provide very brief explanations (max 20 words).
      3. Focus on accuracy over verbosity.

      Each question must have:
      1. A clear question string.
      2. Exactly 4 options.
      3. The correct answer index (0-3).
      4. A brief explanation of the correct answer.

      Return ONLY a JSON object with a key "quiz" containing a list of 10 questions.

      JSON Structure:
      {
        "quiz": [{
          "question": "string",
          "options": ["string", "string", "string", "string"],
          "correctIndex": number,
          "explanation": "string"
        }]
      }
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      String textContent = text.trim();

      final start = textContent.indexOf('{');
      final end = textContent.lastIndexOf('}');

      if (start != -1 && end != -1 && end > start) {
        textContent = textContent.substring(start, end + 1);
        final data = jsonDecode(textContent);
        return List<Map<String, dynamic>>.from(data['quiz'] ?? []);
      }
      return [];
    } catch (e) {
      print('DEBUG: Gemini Quiz Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> generateInterviewQuestions(
      String topic, String careerGoal) async {
    final prompt = '''
      You are an expert technical interviewer at a top-tier tech company.
      Target Career Goal: $careerGoal
      Topic to Cover: $topic

      Generate the 12 MOST ASKED interview questions for this topic and career goal.
      Include a mix of theory, practical application, and scenario-based questions.

      Requirements:
      1. Provide exactly 12 questions.
      2. For each question, provide a clear, professional answer.
      3. Focus on quality and industry standards.
      4. Return the data ONLY as a JSON object with a key "interview_questions".

      JSON Structure:
      {
        "interview_questions": [
          {
            "question": "string",
            "answer": "string"
          },
          ...
        ]
      }
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response from Gemini');

      String textContent = text.trim();
      final start = textContent.indexOf('{');
      final end = textContent.lastIndexOf('}');

      if (start != -1 && end != -1 && end > start) {
        textContent = textContent.substring(start, end + 1);
        final data = jsonDecode(textContent);
        return List<Map<String, dynamic>>.from(
            data['interview_questions'] ?? []);
      }
      return [];
    } catch (e) {
      print('DEBUG: Gemini Interview Questions Error: $e');
      return [];
    }
  }
}
