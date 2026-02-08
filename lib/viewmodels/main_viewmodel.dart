import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/career_role_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../data/career_roles_data.dart';

class MainViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _currentUser;
  List<CareerRoleModel> _roles = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _userRank = 0;

  UserModel? get currentUser => _currentUser;
  List<CareerRoleModel> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get userRank => _userRank;

  List<String> get allSkills {
    final Set<String> skillSet = {};
    for (var role in _roles) {
      skillSet.addAll(role.requiredSkills);
    }
    final sortedSkills = skillSet.toList()..sort();
    return sortedSkills;
  }

  bool get isProfileComplete =>
      _currentUser != null &&
      _currentUser!.education != null &&
      _currentUser!.careerGoal != null;

  void onUserChanged(String? uid) {
    if (uid == null) {
      _currentUser = null;
      _roles = [];
      _errorMessage = null;
      notifyListeners();
    } else {
      fetchUserProfile(uid);
      fetchCareerRoles();
    }
  }

  Future<void> fetchUserProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _dbService.getUserProfile(uid);
      if (_currentUser != null) {
        await _checkStreak(_currentUser!);
        await fetchUserRank();
        if (_currentUser!.lastLearningTime != null) {
          NotificationService()
              .scheduleDailyReminder(_currentUser!.lastLearningTime!);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkStreak(UserModel user) async {
    if (user.lastStreakUpdate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastUpdate = DateTime(
      user.lastStreakUpdate!.year,
      user.lastStreakUpdate!.month,
      user.lastStreakUpdate!.day,
    );

    final difference = today.difference(lastUpdate).inDays;

    if (difference > 1 && user.currentStreak > 0) {
      final updatedUser = user.copyWith(currentStreak: 0);
      await saveUserProfile(updatedUser);
    }
  }

  Future<void> fetchUserRank() async {
    if (_currentUser == null) return;
    try {
      _userRank = await _dbService.getUserRank(_currentUser!.points);
    } catch (e) {
      print('ERROR: Failed to fetch rank: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateLastLearningTime() async {
    if (_currentUser == null) return;
    final now = DateTime.now();
    _currentUser = _currentUser!.copyWith(lastLearningTime: now);
    await _dbService.saveUserProfile(_currentUser!);
    await NotificationService().scheduleDailyReminder(now);
    notifyListeners();
  }

  Future<void> saveUserProfile(UserModel user) async {
    _errorMessage = null;
    try {
      await _dbService.saveUserProfile(user);
      _currentUser = user;
    } catch (e) {
      _errorMessage = 'Failed to save profile.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  bool _isRolesLoading = false;
  bool get isRolesLoading => _isRolesLoading;

  Future<void> fetchCareerRoles() async {
    if (_roles.isNotEmpty) return;
    _isRolesLoading = true;
    notifyListeners();
    try {
      _roles = await _dbService.getCareerRoles();
      // Provide default roles if the database is empty
      if (_roles.isEmpty) {
        _roles = getInitialCareerRoles();
      }
    } catch (e) {
      print('ERROR: Failed to fetch roles: $e');
    } finally {
      _isRolesLoading = false;
      notifyListeners();
    }
  }

  void selectCareerGoal(String goal) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(careerGoal: goal);
      saveUserProfile(updatedUser);
    }
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}
