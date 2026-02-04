import 'dart:io';
import 'package:flutter/material.dart';
import '../models/skill_model.dart';
import '../services/skill_parser_service.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class SkillViewModel extends ChangeNotifier {
  final SkillParserService _parserService = SkillParserService();
  final StorageService _storageService = StorageService();
  final DatabaseService _dbService = DatabaseService();

  List<SkillModel> _extractedSkills = [];
  String? _suggestedGoal;
  bool _isProcessing = false;
  double _readinessScore = 0.0;
  String? _errorMessage;

  List<SkillModel> get extractedSkills => _extractedSkills;
  String? get suggestedGoal => _suggestedGoal;
  bool get isProcessing => _isProcessing;
  double get readinessScore => _readinessScore;
  String? get errorMessage => _errorMessage;

  Future<void> processResume(String uid, File file) async {
    _isProcessing = true;
    _errorMessage = null;
    _suggestedGoal = null;
    notifyListeners();

    try {
      // 1. Upload to Storage
      await _storageService.uploadResume(uid, file);

      // 2. Extract Text
      String text = await _parserService.extractTextFromPdf(file);

      // 3. Parse Skills and Goal
      final result = await _parserService.parseSkills(text);
      _extractedSkills = result['skills'] as List<SkillModel>;
      _suggestedGoal = result['suggestedGoal'] as String?;

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Failed to process resume: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveExtractedSkills(UserModel user) async {
    if (_extractedSkills.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final newSkills = _extractedSkills.map((s) => s.name).toList();
      final updatedSkills = Set<String>.from(user.manualSkills)
        ..addAll(newSkills);

      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        education: user.education,
        department: user.department,
        careerGoal: user.careerGoal ?? _suggestedGoal,
        manualSkills: updatedSkills.toList(),
      );

      await _dbService.saveUserProfile(updatedUser);
      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Failed to save skills: $e';
      notifyListeners();
    }
  }

  void calculateReadiness(
      List<String> requiredSkills, List<String> userSkills) {
    _readinessScore =
        _parserService.calculateReadinessScore(userSkills, requiredSkills);
    notifyListeners();
  }
}
