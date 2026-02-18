import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/simulation_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/career_simulation_model.dart';
import '../widgets/gradient_app_bar.dart';
import '../../constants/app_theme.dart';

class FutureYouScreen extends StatefulWidget {
  const FutureYouScreen({super.key});

  @override
  State<FutureYouScreen> createState() => _FutureYouScreenState();
}

class _FutureYouScreenState extends State<FutureYouScreen> {
  final TextEditingController _currentRoleController = TextEditingController();
  final TextEditingController _targetRoleController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  @override
  void dispose() {
    _currentRoleController.dispose();
    _targetRoleController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SimulationViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Future You Simulator'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputSection(isDark, viewModel),
              const SizedBox(height: 24),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.errorMessage != null)
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (viewModel.simulationResult != null)
                _buildResults(context, viewModel.simulationResult!, isDark),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mainVM = Provider.of<MainViewModel>(context,
          listen:
              false); // MainViewModel needs to be imported if not already, but it's likely available via context in build, however initState runs before build.
      // Wait, I need to check if MainViewModel is imported in this file. It is NOT.
      // I should add the import first.
      if (mainVM.currentUser != null) {
        _skillsController.text = mainVM.currentUser!.manualSkills.join(', ');
        // Also pre-fill career goal if available as target role?
        if (mainVM.currentUser!.careerGoal != null) {
          _targetRoleController.text = mainVM.currentUser!.careerGoal!;
        }
      }
    });
  }

  Widget _buildInputSection(bool isDark, SimulationViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _currentRoleController,
              decoration: const InputDecoration(
                labelText: 'Current Role (e.g. Junior Dev)',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Top Skills (comma separated)',
                prefixIcon: Icon(Icons.code),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetRoleController,
              decoration: const InputDecoration(
                labelText: 'Target Dream Role',
                prefixIcon: Icon(Icons.star),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentRoleController.text.isEmpty ||
                      _targetRoleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in roles to simulate.')),
                    );
                    return;
                  }
                  final skills = _skillsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  viewModel.runSimulation(
                    currentRole: _currentRoleController.text,
                    currentSkills: skills,
                    targetRole: _targetRoleController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simulate My Future',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
      BuildContext context, CareerSimulationModel data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your 5-Year Trajectory",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSalaryChart(data.salaryProjection, isDark),
        const SizedBox(height: 24),
        Text(
          "Key Milestones",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.timelineEvents.length,
          itemBuilder: (context, index) {
            final event = data.timelineEvents[index];
            return _buildTimelineItem(
                event, index == data.timelineEvents.length - 1, isDark);
          },
        ),
        const SizedBox(height: 24),
        Text(
          "Recommended Skills",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.recommendedSkills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.primary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalaryChart(Map<String, dynamic> salaryData, bool isDark) {
    // Simple visual representation
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estimated Salary Growth",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: salaryData.entries.map((e) {
              return Column(
                children: [
                  Text(e.key.toUpperCase(),
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(e.value.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, bool isLast, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Year ${event.yearOffset}: ${event.title}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(event.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(event.type),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'promotion':
        return Colors.green;
      case 'learning':
        return Colors.blue;
      case 'milestone':
      default:
        return Colors.purple;
    }
  }
}
