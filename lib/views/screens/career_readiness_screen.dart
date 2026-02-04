import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../viewmodels/skill_viewmodel.dart';
import 'roadmap_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class CareerReadinessScreen extends StatelessWidget {
  final String roleTitle;
  final List<String> missingSkills;

  const CareerReadinessScreen(
      {super.key, required this.roleTitle, required this.missingSkills});

  @override
  Widget build(BuildContext context) {
    final skillVM = context.watch<SkillViewModel>();
    final score = skillVM.readinessScore;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Career Readiness'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Readiness for $roleTitle',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 15.0,
                percent: score,
                center: Text(
                  "${(score * 100).toInt()}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 32.0),
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    _getFeedbackMessage(score),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.grey),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: _getColor(score),
                animation: true,
              ),
              const SizedBox(height: 60),
              if (missingSkills.isNotEmpty)
                GradientButton(
                  text: 'Generate Learning Roadmap',
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      context
                          .read<RoadmapViewModel>()
                          .generateRoadmap(user.uid, roleTitle, missingSkills);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RoadmapScreen()));
                    }
                  },
                  icon: Icons.auto_awesome,
                )
              else
                const Text(
                    'Congratulations! You are fully ready for this role.',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  String _getFeedbackMessage(double score) {
    if (score >= 0.8)
      return "You're almost there! Just a few more skills to master.";
    if (score >= 0.5)
      return "Good progress! Focus on the missing skills to advance.";
    return "Keep learning! Follow the roadmap to reach your goal.";
  }

  Color _getColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
