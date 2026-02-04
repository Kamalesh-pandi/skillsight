import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/skill_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/skill_model.dart';
import 'skill_analysis_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class SkillExtractionScreen extends StatelessWidget {
  const SkillExtractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skillVM = context.watch<SkillViewModel>();
    final skills = skillVM.extractedSkills;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Extracted Skills'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'We found ${skills.length} skills in your resume!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return ListTile(
                  leading: _getCategoryIcon(skill.category),
                  title: Text(skill.name),
                  subtitle: Text(skill.category.name.toUpperCase()),
                  trailing: _buildProficiencyChip(skill.proficiency),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GradientButton(
              text: 'Continue to Analysis',
              onPressed: skillVM.isProcessing
                  ? null
                  : () async {
                      final mainVM =
                          Provider.of<MainViewModel>(context, listen: false);
                      if (mainVM.currentUser != null) {
                        await skillVM.saveExtractedSkills(mainVM.currentUser!);
                      }
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SkillAnalysisScreen()));
                      }
                    },
              isLoading: skillVM.isProcessing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(SkillCategory category) {
    switch (category) {
      case SkillCategory.programming:
        return const Icon(Icons.code, color: Colors.blue);
      case SkillCategory.frameworks:
        return const Icon(Icons.layers, color: Colors.orange);
      case SkillCategory.tools:
        return const Icon(Icons.build, color: Colors.grey);
      case SkillCategory.softSkills:
        return const Icon(Icons.people, color: Colors.green);
    }
  }

  Widget _buildProficiencyChip(Proficiency proficiency) {
    Color color;
    Color textColor;
    switch (proficiency) {
      case Proficiency.beginner:
        color = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      case Proficiency.intermediate:
        color = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case Proficiency.advanced:
        color = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
    }
    return Chip(
      label: Text(
        proficiency.name,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }
}
