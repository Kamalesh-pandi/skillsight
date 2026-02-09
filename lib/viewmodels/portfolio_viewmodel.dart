import 'package:flutter/material.dart';
import '../models/portfolio_analysis_model.dart';
import '../services/ai_service.dart';

class PortfolioViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  PortfolioAnalysisModel? _analysis;
  PortfolioAnalysisModel? get analysis => _analysis;

  Future<void> analyzePortfolio(String url, String careerGoal) async {
    _isLoading = true;
    _error = null;
    _analysis = null;
    notifyListeners();

    try {
      final result = await _aiService.analyzePortfolio(url, careerGoal);
      _analysis = result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAnalysis() {
    _analysis = null;
    _error = null;
    notifyListeners();
  }
}
