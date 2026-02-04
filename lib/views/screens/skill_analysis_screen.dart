import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../viewmodels/skill_viewmodel.dart';
import '../../models/skill_model.dart';
import 'career_goal_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class SkillAnalysisScreen extends StatelessWidget {
  const SkillAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skillVM = context.watch<SkillViewModel>();
    final skills = skillVM.extractedSkills;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Skill Analysis'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (skillVM.suggestedGoal != null &&
                skillVM.suggestedGoal!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('Suggested Career Path',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      skillVM.suggestedGoal!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text('Your Proficiency Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...skills.map((skill) => _buildSkillProgress(context, skill)),
            const SizedBox(height: 32),
            Center(
              child: GradientButton(
                text: 'Compare with Career Goal',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CareerGoalScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgress(BuildContext context, SkillModel skill) {
    double percent = 0.3;
    if (skill.proficiency == Proficiency.intermediate) percent = 0.6;
    if (skill.proficiency == Proficiency.advanced) percent = 0.9;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(skill.proficiency.name.toUpperCase(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 10.0,
            percent: percent,
            barRadius: const Radius.circular(5),
            progressColor: _getColor(skill.proficiency),
            backgroundColor: Colors.grey[200]!,
            animation: true,
          ),
        ],
      ),
    );
  }

  Color _getColor(Proficiency proficiency) {
    switch (proficiency) {
      case Proficiency.beginner:
        return Colors.blue;
      case Proficiency.intermediate:
        return Colors.orange;
      case Proficiency.advanced:
        return Colors.green;
    }
  }
}
