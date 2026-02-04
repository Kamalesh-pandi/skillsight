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
          if (skillVM.companyReadiness.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Opportunity Readiness',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: skillVM.companyReadiness.length,
                itemBuilder: (context, index) {
                  final readiness = skillVM.companyReadiness[index];
                  final company = readiness['company'] ?? 'Unknown';
                  final score = readiness['score'] ?? 0;

                  return Container(
                    width: 140,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          company,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$score%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(indent: 20, endIndent: 20, height: 32),
          ],
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
