import 'package:flutter/material.dart';
import '../models/course_recommendation_model.dart';

import '../services/ai_service.dart';

class CourseRecommenderViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<CourseRecommendationModel> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  bool? _filterIsPaid; // null = all, true = paid, false = free
  String? _filterDuration; // null, "short", "medium", "long"

  List<CourseRecommendationModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool? get filterIsPaid => _filterIsPaid;
  String? get filterDuration => _filterDuration;

  // Store last query to support re-fetching with filters
  String? _lastCareerGoal;
  List<String>? _lastMissingSkills;

  void setPaidFilter(bool? value) {
    if (_filterIsPaid == value) return;
    _filterIsPaid = value;
    notifyListeners();
    _refetch();
  }

  void setDurationFilter(String? value) {
    if (_filterDuration == value) return;
    _filterDuration = value;
    notifyListeners();
    _refetch();
  }

  void _refetch() {
    if (_lastCareerGoal != null) {
      fetchRecommendations(_lastCareerGoal!, _lastMissingSkills ?? []);
    }
  }

  Future<void> fetchRecommendations(
      String careerGoal, List<String> missingSkills) async {
    _lastCareerGoal = careerGoal;
    _lastMissingSkills = missingSkills;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendations = await _aiService.fetchCourseRecommendations(
        careerGoal,
        missingSkills,
        isPaid: _filterIsPaid,
        maxDuration: _filterDuration,
      );
    } catch (e) {
      _errorMessage = "Failed to load courses: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
