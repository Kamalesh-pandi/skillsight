import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/industry_trend_model.dart';
import '../../services/ai_service.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../widgets/gradient_app_bar.dart';

class IndustryDemandScreen extends StatefulWidget {
  const IndustryDemandScreen({super.key});

  @override
  State<IndustryDemandScreen> createState() => _IndustryDemandScreenState();
}

class _IndustryDemandScreenState extends State<IndustryDemandScreen> {
  bool _isLoading = true;
  IndustryTrendModel? _trendData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mainVM = Provider.of<MainViewModel>(context, listen: false);
      final user = mainVM.currentUser;

      if (user == null || user.careerGoal == null) {
        throw Exception("User or Career Goal not found.");
      }

      // Combine manual skills and any other skills (mocking for now as we don't have a full extracted list in user model consistently available in this context without parsing)
      // Realistically we should use user.manualSkills
      final aiService =
          AIService(); // Using directly for now, ideally via Provider
      final data = await aiService.fetchIndustryTrends(
        user.careerGoal!,
        user.manualSkills,
      );

      if (data == null) {
        throw Exception("Failed to analyze market data.");
      }

      if (mounted) {
        setState(() {
          _trendData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Real-Time Market Analysis'),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Analyzing Live Job Market...",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text("Error: $_error"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Score Section
                      Center(
                        child: Column(
                          children: [
                            CircularPercentIndicator(
                              radius: 80.0,
                              lineWidth: 12.0,
                              animation: true,
                              percent: (_trendData?.matchScore ?? 0) / 100,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${_trendData?.matchScore.toInt()}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32.0),
                                  ),
                                  const Text("Match",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.0)),
                                ],
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: AppColors.primary,
                              backgroundColor: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Your Profile vs Market Demand",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Hot Skills
                      Text("🔥 Emerging 'Hot' Skills",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _trendData!.hotSkills
                            .map((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor:
                                      Colors.orange.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold),
                                  side: BorderSide.none,
                                  avatar: const Icon(
                                      Icons.local_fire_department,
                                      size: 18,
                                      color: Colors.deepOrange),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 32),

                      // Top Demanded Skills
                      Text("Most In-Demand Skills",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ..._trendData!.topSkills.map((skill) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(skill.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Text("${skill.demandPercentage}% Demand",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearPercentIndicator(
                                  lineHeight: 8.0,
                                  percent: (skill.demandPercentage / 100)
                                      .clamp(0.0, 1.0), // Ensure valid range
                                  progressColor: _getColorForLevel(skill.level),
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  barRadius: const Radius.circular(4),
                                  animation: true,
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 32),

                      // Missing Skills
                      if (_trendData!.missingSkills.isNotEmpty) ...[
                        Text("⚠️ Critical Gaps to FIll",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _trendData!.missingSkills
                                .map((skill) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.warning_amber_rounded,
                                              size: 16,
                                              color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(skill,
                                                style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white70
                                                        : Colors.black87),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh Market Data"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}
