import 'package:flutter/material.dart';
import '../models/roadmap_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart'; // Assuming AIService is in this file
import 'package:uuid/uuid.dart';

class RoadmapViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService = AIService();
  RoadmapModel? _currentRoadmap;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, Future<List<Map<String, dynamic>>>> _quizFetches = {};

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

  Future<void> toggleTaskCompletion(int weekIndex, int taskIndex, bool value,
      UserModel? currentUser, Function(UserModel)? onUserUpdate) async {
    if (_currentRoadmap != null) {
      await _dbService.updateRoadmapTask(
          _currentRoadmap!.id, weekIndex, taskIndex, value);

      final oldTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
          oldTask.copyWith(isCompleted: value);

      // Streak Logic
      if (value && currentUser != null && onUserUpdate != null) {
        await _updateStreak(
            currentUser, onUserUpdate, 10); // Default 10 for manual toggle
      }

      notifyListeners();
    }
  }

  Future<void> _updateStreak(UserModel user, Function(UserModel) onUserUpdate,
      int earnedPoints) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastUpdate = user.lastStreakUpdate != null
        ? DateTime(user.lastStreakUpdate!.year, user.lastStreakUpdate!.month,
            user.lastStreakUpdate!.day)
        : null;

    int newStreak = user.currentStreak;
    int newPoints = user.points + earnedPoints;

    if (lastUpdate == null) {
      newStreak = 1;
    } else if (today.isAfter(lastUpdate)) {
      final difference = today.difference(lastUpdate).inDays;
      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
      // If difference is 0 (same day), streak stays the same
    }

    final updatedUser = user.copyWith(
      currentStreak: newStreak,
      longestStreak:
          newStreak > user.longestStreak ? newStreak : user.longestStreak,
      lastStreakUpdate: now,
      points: newPoints,
    );

    await _dbService.saveUserProfile(updatedUser);
    onUserUpdate(updatedUser);
  }

  Future<void> fetchResourcesForTask(int weekIndex, int taskIndex) async {
    if (_currentRoadmap == null) return;

    final task = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

    // If already fetched, don't fetch again
    if (task.bestResources != null && task.youtubeQuery != null) return;

    try {
      final resources = await _aiService.fetchTaskResources(
          task.title, _currentRoadmap!.careerGoal);

      // Re-fetch task to avoid race conditions with other background updates
      final latestTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = latestTask.copyWith(
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
    if (weekIndex >= _currentRoadmap!.weeks.length) return [];
    if (taskIndex >= _currentRoadmap!.weeks[weekIndex].tasks.length) return [];

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
        // Re-fetch latest task to ensure we don't overwrite other field updates
        final latestTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
        _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
            latestTask.copyWith(
          quizQuestions: questions,
        );
        await _dbService.saveRoadmap(_currentRoadmap!);
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

  Future<void> saveQuizScore(
    int weekIndex,
    int taskIndex,
    int score,
    bool passed, {
    UserModel? currentUser,
    Function(UserModel)? onUserUpdate,
  }) async {
    if (_currentRoadmap == null) return;
    if (weekIndex >= _currentRoadmap!.weeks.length) return;
    if (taskIndex >= _currentRoadmap!.weeks[weekIndex].tasks.length) return;

    final oldTask = _currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
    final wasAlreadyCompleted = oldTask.isCompleted;

    // 1. Update Roadmap Locally
    _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] = oldTask.copyWith(
      quizScore: score,
      lastTestedAt: DateTime.now(),
      isCompleted: wasAlreadyCompleted || passed,
    );

    // 2. Persist Roadmap
    await _dbService.saveRoadmap(_currentRoadmap!);

    // 3. Update User Progress (Points & Streak) if newly passed
    if (passed &&
        !wasAlreadyCompleted &&
        currentUser != null &&
        onUserUpdate != null) {
      await _updateStreak(currentUser, onUserUpdate, score);
    }

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

      _currentRoadmap!.weeks[weekIndex].tasks[taskIndex] =
          task.copyWith(interviewQuestions: questions);

      await _dbService.saveRoadmap(_currentRoadmap!);
      notifyListeners();
    } catch (e) {
      print('DEBUG: RoadmapVM Interview Error: $e');
    }
  }
}
