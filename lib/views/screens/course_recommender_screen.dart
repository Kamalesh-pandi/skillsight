import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/course_recommender_viewmodel.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../constants/app_theme.dart';
import '../../models/course_recommendation_model.dart';

class CourseRecommenderScreen extends StatefulWidget {
  const CourseRecommenderScreen({super.key});

  @override
  State<CourseRecommenderScreen> createState() =>
      _CourseRecommenderScreenState();
}

class _CourseRecommenderScreenState extends State<CourseRecommenderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  void _loadRecommendations() {
    final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);
    final courseVM =
        Provider.of<CourseRecommenderViewModel>(context, listen: false);

    final careerGoal =
        roadmapVM.currentRoadmap?.careerGoal ?? 'Software Developer';
    // We can get missing skills from roadmap tasks that are not completed?
    // Or just generic query. For now, let's use a generic query if specific skills aren't easily available as a list.
    // Actually, we can assume the user wants recommendations for their current goal.

    // Let's try to extract some context from the roadmap if possible, or just pass empty stats and let AI decide based on goal.
    final List<String> contextSkills = [];
    // If we wanted to be specific:
    // contextSkills.addAll(roadmapVM.currentRoadmap?.weeks.expand((w) => w.tasks).where((t) => !t.isCompleted).map((t) => t.title).take(5) ?? []);

    courseVM.fetchRecommendations(careerGoal, contextSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Recommendations'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Consumer<CourseRecommenderViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              _buildFilters(vm),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.errorMessage != null
                        ? Center(child: Text(vm.errorMessage!))
                        : vm.recommendations.isEmpty
                            ? const Center(
                                child: Text('No recommendations found.'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: vm.recommendations.length,
                                itemBuilder: (context, index) {
                                  final course = vm.recommendations[index];
                                  return _buildCourseCard(course);
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(CourseRecommenderViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
            bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Filter by:",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: "All Prices",
                  isSelected: vm.filterIsPaid == null,
                  onSelected: (_) => vm.setPaidFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: "Free Only",
                  isSelected: vm.filterIsPaid == false,
                  onSelected: (_) => vm.setPaidFilter(false),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: "Paid/Cert",
                  isSelected: vm.filterIsPaid == true,
                  onSelected: (_) => vm.setPaidFilter(true),
                ),
                const SizedBox(width: 16),
                Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).dividerColor.withOpacity(0.2)),
                const SizedBox(width: 16),
                _buildFilterChip(
                  label: "Any Duration",
                  isSelected: vm.filterDuration == null,
                  onSelected: (_) => vm.setDurationFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: "Short (<10h)",
                  isSelected: vm.filterDuration == "short",
                  onSelected: (_) => vm.setDurationFilter("short"),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: "Medium (10-40h)",
                  isSelected: vm.filterDuration == "medium",
                  onSelected: (_) => vm.setDurationFilter("medium"),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: "Long (40h+)",
                  isSelected: vm.filterDuration == "long",
                  onSelected: (_) => vm.setDurationFilter("long"),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: _loadRecommendations,
                  tooltip: "Refresh Recommendations",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).textTheme.bodyMedium?.color),
    );
  }

  Widget _buildCourseCard(CourseRecommendationModel course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(course.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open course URL')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (course.isPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(course.price,
                          style: TextStyle(
                              color: isDark
                                  ? Colors.amberAccent
                                  : Colors.amber.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("FREE",
                          style: TextStyle(
                              color: isDark
                                  ? Colors.greenAccent
                                  : Colors.green.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.monitor,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    TextSpan(text: course.platform),
                    const WidgetSpan(child: SizedBox(width: 16)),
                    WidgetSpan(
                      child: Icon(
                        Icons.timer,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    TextSpan(text: course.duration),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(course.rating.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(course.level,
                        style: TextStyle(
                            color: isDark
                                ? Colors.blueAccent
                                : Colors.blue.shade800,
                            fontSize: 11)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: course.skills
                    .take(3)
                    .map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 10)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(context).cardTheme.color,
                          side: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.2)),
                        ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
