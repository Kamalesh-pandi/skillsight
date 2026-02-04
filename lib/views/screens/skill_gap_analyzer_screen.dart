import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/skill_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/career_role_model.dart';
import 'career_readiness_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class SkillGapAnalyzerScreen extends StatelessWidget {
  final CareerRoleModel selectedRole;

  const SkillGapAnalyzerScreen({super.key, required this.selectedRole});

  @override
  Widget build(BuildContext context) {
    final skillVM = context.watch<SkillViewModel>();
    final mainVM = context.watch<MainViewModel>();

    // Combine manual skills from profile and extracted skills from resume
    final manualSkills = mainVM.currentUser?.manualSkills ?? [];
    final extractedSkills = skillVM.extractedSkills.map((s) => s.name).toList();

    final allUserSkills = {...manualSkills, ...extractedSkills}
        .map((s) => s.toLowerCase())
        .toSet();

    final matchedSkills = selectedRole.requiredSkills
        .where((skill) => allUserSkills.contains(skill.toLowerCase()))
        .toList();
    final missingSkills = selectedRole.requiredSkills
        .where((skill) => !allUserSkills.contains(skill.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Skill Gap Analyzer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comparing with: ${selectedRole.title}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            _buildSection(
                context, 'Matched Skills', matchedSkills, Colors.green),
            const SizedBox(height: 24),
            _buildSection(context, 'Missing Skills', missingSkills, Colors.red),
            const SizedBox(height: 40),
            Center(
              child: GradientButton(
                text: 'Check Career Readiness',
                onPressed: () {
                  final manualSkills = mainVM.currentUser?.manualSkills ?? [];
                  final extractedSkills =
                      skillVM.extractedSkills.map((s) => s.name).toList();
                  final combinedSkills =
                      {...manualSkills, ...extractedSkills}.toList();

                  skillVM.calculateReadiness(
                      selectedRole.requiredSkills, combinedSkills);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CareerReadinessScreen(
                        roleTitle: selectedRole.title,
                        missingSkills: missingSkills,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(title.contains('Matched') ? Icons.check_circle : Icons.error,
                color: color),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.isEmpty
              ? [
                  Text('None',
                      style: TextStyle(color: Theme.of(context).hintColor))
                ]
              : skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: color.withOpacity(0.1),
                        side: BorderSide(color: color),
                      ))
                  .toList(),
        ),
      ],
    );
  }
}
