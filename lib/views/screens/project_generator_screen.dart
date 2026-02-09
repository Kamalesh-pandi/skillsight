import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/project_suggestion_model.dart';
import '../../services/ai_service.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../widgets/gradient_app_bar.dart';

class ProjectGeneratorScreen extends StatefulWidget {
  const ProjectGeneratorScreen({super.key});

  @override
  State<ProjectGeneratorScreen> createState() => _ProjectGeneratorScreenState();
}

class _ProjectGeneratorScreenState extends State<ProjectGeneratorScreen> {
  bool _isLoading = true;
  ProjectSuggestionModel? _project;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateProject();
  }

  Future<void> _generateProject() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _project = null;
    });

    try {
      final mainVM = Provider.of<MainViewModel>(context, listen: false);
      final user = mainVM.currentUser;
      final careerGoal = user?.careerGoal ?? 'Software Developer';
      final currentSkills = user?.manualSkills ?? [];

      // Fetch skill gaps from industry trends
      final aiService = AIService();
      final trends =
          await aiService.fetchIndustryTrends(careerGoal, currentSkills);
      final skillGaps = trends?.missingSkills ?? [];

      final project =
          await aiService.generatePortfolioProject(careerGoal, skillGaps);

      if (mounted) {
        setState(() {
          _project = project;
          _isLoading = false;
          if (project == null) _error = 'Failed to generate project.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Personalized Project Generator'),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Generating your personalized project...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _project != null
                  ? _buildProjectContent(isDark)
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateProject,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectContent(bool isDark) {
    final p = _project!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Idea
          _buildSection(
            icon: Icons.lightbulb_outline,
            title: 'Project Idea',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                p.projectIdea,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tech Stack
          _buildSection(
            icon: Icons.code,
            title: 'Tech Stack',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.techStack
                  .map((tech) => Chip(
                        label: Text(tech),
                        backgroundColor: AppColors.secondary.withOpacity(0.15),
                        side: BorderSide(
                            color: AppColors.secondary.withOpacity(0.3)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Step-by-Step Build Plan
          _buildSection(
            icon: Icons.list_alt,
            title: 'Step-by-Step Build Plan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: p.buildPlan.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // GitHub Structure
          _buildSection(
            icon: Icons.folder_outlined,
            title: 'GitHub Structure',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: p.githubStructure
                    .map((path) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                path.endsWith('/')
                                    ? Icons.folder_outlined
                                    : Icons.insert_drive_file_outlined,
                                size: 18,
                                color: path.endsWith('/')
                                    ? Colors.amber
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  path,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Regenerate Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateProject,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Another Project'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
