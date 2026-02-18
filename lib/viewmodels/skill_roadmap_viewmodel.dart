import 'package:flutter/material.dart';
import '../models/roadmap_model.dart';
import '../services/ai_service.dart';
import 'package:uuid/uuid.dart';

class SkillRoadmapViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();
  RoadmapModel? _currentRoadmap;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInterviewMode = false;
  final Map<String, Future<List<Map<String, dynamic>>>> _quizFetches = {};

  String? _currentSkill;

  RoadmapModel? get currentRoadmap => _currentRoadmap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInterviewMode => _isInterviewMode;

  double get completionPercentage {
    if (_currentRoadmap == null || _currentRoadmap!.weeks.isEmpty) return 0.0;
    int totalTasks = 0;
    int completedTasks = 0;
    for (var week in _currentRoadmap!.weeks) {
      totalTasks += week.tasks.length;
      completedTasks += week.tasks.where((t) => t.isCompleted).length;
    }
    return totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);
  }

  Future<void> generateSkillRoadmap(String skillName) async {
    // If we already have the roadmap for this skill, don't regenerate
    if (_currentSkill == skillName && _currentRoadmap != null) {
      return;
    }

    _currentSkill = skillName;
    _isLoading = true;
    _errorMessage = null;
    _currentRoadmap = null; // Reset previous
    notifyListeners();

    try {
      // mimic a career goal of "Mastering [Skill]" and treating the skill itself as the "missing skill"
      // to force the AI to build a roadmap AROUND that skill.
      final careerGoal = 'Mastering $skillName';
      final missingSkills = [skillName];

      final aiRoadmap =
          await _aiService.generateRoadmap(careerGoal, missingSkills);

      List<RoadmapWeek> weeks = aiRoadmap.map((w) {
        return RoadmapWeek(
          weekNumber: w['week'] ?? 0,
          focus: w['focus'] ?? '',
          tasks: (w['tasks'] as List? ?? [])
              .map((t) => RoadmapTask(title: t.toString()))
              .toList(),
        );
      }).toList();

      _currentRoadmap = RoadmapModel(
        id: const Uuid().v4(),
        userId: 'temp-user', // Ephemeral
        careerGoal: careerGoal,
        weeks: weeks,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _errorMessage = 'Failed to generate skill roadmap: $e';
      print('Error generating skill roadmap: $e');
      _currentSkill = null; // Reset on failure so we can try again
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleInterviewMode() {
    _isInterviewMode = !_isInterviewMode;
    // Clear any existing quizzes to force regenerate them in the new mode
    if (_currentRoadmap != null) {
      for (var week in _currentRoadmap!.weeks) {
        for (var task in week.tasks) {
          task.quizQuestions?.clear();
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchResourcesForTask(int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return;
    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

    if (task.bestResources != null && task.youtubeQuery != null) return;

    try {
      final resources = await _aiService.fetchTaskResources(
          task.title, _currentRoadmap!.careerGoal);

      final latestTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = latestTask.copyWith(
        bestResources: resources['bestResources'],
        youtubeQuery: resources['youtubeQuery'],
      );
      notifyListeners();
    } catch (e) {
      print('Error fetching resources: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizForTask(
      int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return [];

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    if (task.quizQuestions != null && task.quizQuestions!.isNotEmpty) {
      return task.quizQuestions!;
    }

    final fetchKey = '${_currentRoadmap!.id}-$weekIndex-$taskIndex';
    if (_quizFetches.containsKey(fetchKey)) {
      return _quizFetches[fetchKey]!;
    }

    final fetchFuture = _aiService.generateQuiz(
        task.title, _currentRoadmap!.careerGoal,
        isInterviewMode: _isInterviewMode);

    _quizFetches[fetchKey] = fetchFuture;

    try {
      final questions = await fetchFuture;
      if (questions.isNotEmpty) {
        final latestTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
        _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
            latestTask.copyWith(
          quizQuestions: questions,
        );
        notifyListeners();
      }
      return questions;
    } catch (e) {
      print('Error fetching quiz: $e');
      return [];
    } finally {
      _quizFetches.remove(fetchKey);
    }
  }

  // Purely local toggle for ephemeral roadmap
  void toggleTaskCompletion(int weekIndex, int taskIndex, bool value) {
    if (_currentRoadmap == null) return;

    final oldTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
        oldTask.copyWith(isCompleted: value);
    notifyListeners();
  }

  Future<void> fetchInterviewQuestions(int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return;

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    if (task.interviewQuestions != null &&
        task.interviewQuestions!.isNotEmpty) {
      return;
    }

    try {
      final questions = await _aiService.generateInterviewQuestions(
          task.title, _currentRoadmap!.careerGoal);

      final latestTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
          latestTask.copyWith(interviewQuestions: questions);
      notifyListeners();
    } catch (e) {
      print('DEBUG: SkillRoadmapVM Interview Error: $e');
      rethrow;
    }
  }
}
