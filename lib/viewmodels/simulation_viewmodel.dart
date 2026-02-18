import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/career_simulation_model.dart';

class SimulationViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  bool _isLoading = false;
  String? _errorMessage;
  CareerSimulationModel? _simulationResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CareerSimulationModel? get simulationResult => _simulationResult;

  Future<void> runSimulation({
    required String currentRole,
    required List<String> currentSkills,
    required String targetRole,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _simulationResult = null;
    notifyListeners();

    try {
      _simulationResult = await _aiService.simulateCareerPath(
        currentRole,
        currentSkills,
        targetRole,
      );

      if (_simulationResult == null) {
        _errorMessage = "Could not generate simulation. Please try again.";
      }
    } catch (e) {
      _errorMessage = "Simulation failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearHelper() {
    _simulationResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
