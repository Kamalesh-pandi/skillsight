import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../models/industry_trend_model.dart';
import '../models/project_suggestion_model.dart';

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
    final int missingCount = missingSkills.length;

    final prompt = '''
You are an expert career coach and technical mentor.
Target Career Goal: $careerGoal
Missing Skills (${missingCount}): ${missingSkills.join(', ')}

YOUR PRIMARY GOAL:
- Build a SKILL DEPENDENCY ROADMAP, not just a flat list.
- Think of concepts like: "Data Science → Python → Variables → Loops → Statistics → Machine Learning".
- Earlier skills must be prerequisites for later ones, and learning order must be obvious from the plan.

STEP 1 – REASON ABOUT DEPENDENCIES (INTERNALLY):
- Before writing the JSON, reason (silently) about:
  - Which skills are FOUNDATIONAL vs INTERMEDIATE vs ADVANCED.
  - Which skills depend on which earlier skills.
- Organize missing skills into a logical progression from basic → intermediate → advanced.
- Make sure there are NO circular dependencies.

STEP 2 – CONVERT TO WEEK-BY-WEEK ROADMAP (OUTPUT):

IMPORTANT RULES (DURATION MUST DEPEND ON SKILLS, NOT STATIC):
- Let missingCount = $missingCount.
- Use this guideline to decide TOTAL WEEKS:
  * If missingCount <= 3  ->  4–6 weeks
  * If 4 <= missingCount <= 7  ->  8–12 weeks
  * If 8 <= missingCount <= 12 ->  12–18 weeks
  * If missingCount  > 12      ->  16–24 weeks
- Never generate a fixed 12-week plan blindly. Adjust total weeks so that each major skill/topic gets enough time.
- Minimum 4 weeks, maximum 24 weeks.

Other constraints:
1. Provide a clear week-by-week breakdown that RESPECTS the dependency order:
   - Earlier weeks should only contain foundational topics.
   - Advanced topics (that depend on earlier skills) must appear in later weeks.
2. For each week, provide:
   - "focus": a short theme that groups related skills (e.g. "Core Python & Basics", "Statistics Foundations", "Intro to Machine Learning").
   - "tasks": 3–6 specific, actionable tasks/topics that help master the focus.
     - Within a week, list tasks in the order they should be learned (prerequisites first).
3. Make sure all listed missing skills are covered across the roadmap in a logical progression from basic to advanced.
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

  Future<IndustryTrendModel?> fetchIndustryTrends(
      String careerGoal, List<String> currentSkills) async {
    final prompt = '''
      You are a Real-Time Market Analyst.
      Analyze the current job market demand for the role: "$careerGoal".
      User's Current Skills: ${currentSkills.join(', ')}

      Provide a "Real-Time" Industry Demand Analysis.
      
      Return ONLY a JSON object with:
      1. "matchScore": A score from 0 to 100 indicating how well the user's skills match the current market demand.
      2. "topSkills": A list of the top 5 most demanding skills for this role right now. Each item should have:
         - "name": Skill name
         - "demandPercentage": Estimated % of job postings requiring this skill (e.g., 85)
         - "level": Required proficiency (Beginner, Intermediate, Advanced)
      3. "hotSkills": A list of 3 emerging or "Hot" skills that are gaining traction fast.
      4. "missingSkills": A list of critical skills the user is missing to be job-ready.

      JSON Structure:
      {
        "matchScore": 75,
        "topSkills": [
          {"name": "Flutter", "demandPercentage": 90, "level": "Advanced"},
          ...
        ],
        "hotSkills": ["Riverpod", "Clean Architecture", "CI/CD"],
        "missingSkills": ["Unit Testing", "CI/CD"]
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
        return IndustryTrendModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('DEBUG: Gemini Industry Trends Error: $e');
      return null;
    }
  }

  Future<ProjectSuggestionModel?> generatePortfolioProject(
      String careerGoal, List<String> skillGaps) async {
    final skillGapsStr = skillGaps.isEmpty
        ? 'general professional skills'
        : skillGaps.join(', ');

    final prompt = '''
      You are an expert career coach and portfolio advisor.
      Target Career Goal: $careerGoal
      User's Skill Gaps (areas to strengthen): $skillGapsStr

      Generate ONE personalized portfolio project that:
      1. Helps fill the user's skill gaps
      2. Is relevant to their career goal
      3. Is achievable as a solo project (2–4 weeks of focused work)
      4. Would impress recruiters and hiring managers

      Return ONLY a JSON object with:
      1. "projectIdea": A compelling project name and 2–3 sentence description of what it does and why it's valuable.
      2. "techStack": List of 4–8 specific technologies/frameworks to use (e.g., "Flutter", "Firebase", "Dart", "Riverpod").
      3. "buildPlan": List of 6–10 step-by-step phases to build the project. Each step should be actionable (e.g., "Set up Firebase Auth and implement login/signup screens").
      4. "githubStructure": List of folder/file paths suggesting the repo structure (e.g., "lib/", "lib/models/", "lib/services/", "README.md").

      JSON Structure:
      {
        "projectIdea": "string",
        "techStack": ["string", "string", ...],
        "buildPlan": ["Step 1...", "Step 2...", ...],
        "githubStructure": ["folder/", "folder/file.dart", ...]
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
        return ProjectSuggestionModel.fromMap(data);
      }
      return null;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('quota')) {
        throw Exception(
            'Firebase AI Quota Exceeded: Please check your Firebase billing or project limits.');
      } else if (errorStr.contains('firebaseml.googleapis.com')) {
        throw Exception('Firebase ML API Disabled: Please enable the API.');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> generateDailyMicroTasks(
    String careerGoal, {
    String? currentFocus,
    List<String>? skillGaps,
    int timeBudgetMinutes = 30,
  }) async {
    final safeSkillGaps =
        (skillGaps ?? []).where((s) => s.trim().isNotEmpty).toList();

    final prompt = '''
You are a friendly career coach.

Goal:
- Generate 3 small learning tasks for TODAY that each take around 10–20 minutes.
- Tasks must be concrete and easy to start immediately.

User context:
- Target role: $careerGoal
- Current roadmap focus (optional): ${currentFocus ?? 'Not specified'}
- Skill gaps to strengthen: ${safeSkillGaps.isEmpty ? 'general fundamentals for this role' : safeSkillGaps.join(', ')}
- Total time budget for today: $timeBudgetMinutes minutes

Guidelines:
- Prefer a mix of formats across coding practice, short videos, and quick revision/notes.
- Each task should be independent and completable in one sitting.
- Avoid long projects, large tutorials, or vague advice like "read about X".
- Where helpful, reference generic platforms only (e.g. "on LeetCode", "on YouTube") without forcing specific URLs.

Return ONLY valid JSON with this structure:
{
  "tasks": [
    {
      "title": "Solve 2 array problems",
      "description": "On LeetCode, filter for Easy array problems and solve any 2, focusing on two-pointer patterns.",
      "skillTag": "DSA – Arrays",
      "durationMinutes": 15
    }
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
      }

      final data = jsonDecode(textContent);
      final rawTasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);

      // Normalise & clamp durations
      return rawTasks
          .map((task) {
            final title = task['title']?.toString().trim() ?? '';
            if (title.isEmpty) return null;

            int duration = 15;
            final rawDuration = task['durationMinutes'];
            if (rawDuration is num) {
              duration = rawDuration.clamp(5, 30).toInt();
            }

            return {
              'title': title,
              'description': task['description']?.toString().trim() ?? '',
              'skillTag': task['skillTag']?.toString().trim() ?? '',
              'durationMinutes': duration,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();
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
}
