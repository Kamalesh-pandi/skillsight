import 'package:flutter/material.dart';
import '../models/roadmap_model.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart'; // Assuming AIService is in this file
import 'package:uuid/uuid.dart';

class RoadmapViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService = AIService();
  RoadmapModel? _currentRoadmap;
  bool _isLoading = false;
  String? _errorMessage;

  RoadmapModel? get currentRoadmap => _currentRoadmap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<void> generateRoadmap(
      String userId, String careerGoal, List<String> missingSkills) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
        userId: userId,
        careerGoal: careerGoal,
        weeks: weeks,
        createdAt: DateTime.now(),
      );

      await _dbService.saveRoadmap(_currentRoadmap!);
    } catch (e) {
      _errorMessage = 'Failed to generate roadmap: $e';
      print('Error generating AI roadmap: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoadmap(String userId) async {
    if (_currentRoadmap != null && _currentRoadmap!.userId == userId) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentRoadmap = await _dbService.getRoadmap(userId);
    } catch (e) {
      _errorMessage = 'Failed to fetch roadmap: $e';
      print('Error fetching roadmap: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _currentRoadmap = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(
      int weekIndex, int taskIndex, bool value) async {
    if (_currentRoadmap != null) {
      await _dbService.updateRoadmapTask(
          _currentRoadmap!.id, weekIndex, taskIndex, value);

      final oldTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
          oldTask.copyWith(isCompleted: value);
      notifyListeners();
    }
  }

  Future<void> fetchResourcesForTask(int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return;

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

    // If already fetched, don't fetch again
    if (task.bestResources != null && task.youtubeQuery != null) return;

    try {
      final resources = await _aiService.fetchTaskResources(
          task.title, _currentRoadmap!.careerGoal);

      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = task.copyWith(
        bestResources: resources['bestResources'],
        youtubeQuery: resources['youtubeQuery'],
      );

      await _dbService.saveRoadmap(_currentRoadmap!);
      notifyListeners();
    } catch (e) {
      print('Error fetching resources: $e');
    }
  }

  bool _isInterviewMode = false;
  bool get isInterviewMode => _isInterviewMode;

  void toggleInterviewMode() {
    _isInterviewMode = !_isInterviewMode;
    // Clear any existing quizzes to force regenerate them in the new mode
    if (_currentRoadmap != null) {
      for (var week in _currentRoadmap!.weeks) {
        for (var task in week.tasks) {
          // Reset quiz questions so they are re-fetched with new mode
          // But keep the score/status
          task.quizQuestions?.clear();
        }
      }
    }
    notifyListeners();
  }

  bool isTaskDecaying(int weekIndex, int taskIndex) {
    if (_currentRoadmap == null) return false;
    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    if (task.lastTestedAt == null) return false;

    // Decay if not tested in last 14 days
    final difference = DateTime.now().difference(task.lastTestedAt!);
    return difference.inDays > 14;
  }

  Future<List<Map<String, dynamic>>> fetchQuizForTask(
      int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return [];

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

    // If already has questions AND WE ARE NOT SWITCHING MODES (simplification: simple cache check)
    // For now, if questions exist, return them.
    // Ideally we should clear questions when toggling mode.
    // (Handled in toggleInterviewMode above technically, but list might be empty not null)

    // Logic: If questions exist, return them.
    // If not, fetch. The toggleInterviewMode clears the list.
    if (task.quizQuestions != null && task.quizQuestions!.isNotEmpty) {
      return task.quizQuestions!;
    }

    try {
      final questions = await _aiService.generateQuiz(
          task.title, _currentRoadmap!.careerGoal,
          isInterviewMode: _isInterviewMode);

      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = task.copyWith(
        quizQuestions: questions,
      );

      await _dbService.saveRoadmap(_currentRoadmap!);
      notifyListeners();
      return questions;
    } catch (e) {
      print('Error fetching quiz: $e');
      return [];
    }
  }

  Future<void> saveQuizScore(int weekIndex, int taskIndex, int score) async {
    if (_currentRoadmap == null) return;

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = task.copyWith(
      quizScore: score,
      lastTestedAt: DateTime.now(), // Update last tested time
    );

    await _dbService.saveRoadmap(_currentRoadmap!);
    notifyListeners();
  }
}
