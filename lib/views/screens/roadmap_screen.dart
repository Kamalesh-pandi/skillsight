import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/roadmap_model.dart';
import '../../constants/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';
import 'quiz_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);
      final mainVM = Provider.of<MainViewModel>(context, listen: false);
      if (roadmapVM.currentRoadmap == null && mainVM.currentUser != null) {
        roadmapVM.fetchRoadmap(mainVM.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roadmapVM = context.watch<RoadmapViewModel>();
    final roadmap = roadmapVM.currentRoadmap;

    if (roadmapVM.isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ShimmerLoading.rectangular(height: 240),
              Expanded(child: ShimmerList()),
            ],
          ),
        ),
      );
    }

    if (roadmap == null) {
      if (roadmapVM.errorMessage != null) {
        return _buildErrorState(context, roadmapVM.errorMessage!);
      }
      return _buildEmptyState(context);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, roadmapVM),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final week = roadmap.weeks[index];
                  final isLast = index == roadmap.weeks.length - 1;
                  return _buildTimelineItem(
                    context,
                    week,
                    index,
                    roadmapVM,
                    isLast,
                  );
                },
                childCount: roadmap.weeks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (keeping unchanged _buildEmptyState, _buildErrorState, _buildSliverAppBar, _buildProgressCircle) ...

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Learning Roadmap'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text('No roadmap generated yet.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    )),
            const SizedBox(height: 12),
            const Text('Upload your resume to get started',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: GradientButton(
                text: 'Go back to analyze skills',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    bool isIndexError = error.contains('failed-precondition');
    return Scaffold(
      appBar: const GradientAppBar(title: 'Roadmap Error'),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                isIndexError
                    ? 'Firestore Index Required: A composite index is missing in your Firebase project. Please check the debug console (or the terminal where you ran the app) for the direct link to create it.'
                    : error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              GradientButton(
                text: 'Retry',
                onPressed: () {
                  final roadmapVM =
                      Provider.of<RoadmapViewModel>(context, listen: false);
                  final mainVM =
                      Provider.of<MainViewModel>(context, listen: false);
                  if (mainVM.currentUser != null) {
                    roadmapVM.fetchRoadmap(mainVM.currentUser!.uid);
                  }
                },
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, RoadmapViewModel vm) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Your Learning Path',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Interview Mode',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: vm.isInterviewMode,
                            onChanged: (_) => vm.toggleInterviewMode(),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Overall Progress',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '${(vm.completionPercentage * 100).toInt()}% Complete',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildProgressCircle(vm.completionPercentage),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: vm.completionPercentage,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle(double percentage) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
          const Icon(Icons.auto_graph, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    RoadmapWeek week,
    int weekIndex,
    RoadmapViewModel vm,
    bool isLast,
  ) {
    bool isWeekCompleted = week.tasks.every((t) => t.isCompleted);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isWeekCompleted
                      ? AppColors.success
                      : Theme.of(context).cardTheme.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWeekCompleted
                        ? AppColors.success
                        : AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    if (isWeekCompleted)
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: isWeekCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '${week.weekNumber}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isWeekCompleted
                        ? AppColors.success.withOpacity(0.1)
                        : Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isWeekCompleted
                            ? AppColors.success.withOpacity(0.05)
                            : AppColors.primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 20,
                            color: isWeekCompleted
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Week ${week.weekNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isWeekCompleted
                                    ? AppColors.success
                                    : Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isWeekCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: week.tasks.asMap().entries.map((entry) {
                          int taskIndex = entry.key;
                          RoadmapTask task = entry.value;
                          return InkWell(
                            onTap: () => _showResourceSheet(
                                context, weekIndex, taskIndex),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      if (task.isCompleted) {
                                        return;
                                      }

                                      // If not completed, trigger quiz first
                                      if (!mounted) return;

                                      if (task.quizScore != null &&
                                          task.quizScore! >= 5) {
                                        final mainVM =
                                            Provider.of<MainViewModel>(context,
                                                listen: false);
                                        await vm.toggleTaskCompletion(
                                            weekIndex,
                                            taskIndex,
                                            true,
                                            mainVM.currentUser,
                                            mainVM.updateUser);
                                      } else {
                                        if (mounted) {
                                          _startQuiz(
                                              context, weekIndex, taskIndex);
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: task.isCompleted
                                            ? AppColors.success
                                            : Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: task.isCompleted
                                              ? AppColors.success
                                              : Theme.of(context).dividerColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: task.isCompleted
                                          ? const Icon(Icons.check,
                                              size: 16, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            color: task.isCompleted
                                                ? Theme.of(context).hintColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (task.quizScore != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: task.quizScore! >= 5
                                                    ? AppColors.success
                                                        .withOpacity(0.1)
                                                    : Colors.red
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: task.quizScore! >= 5
                                                      ? AppColors.success
                                                          .withOpacity(0.2)
                                                      : Colors.red
                                                          .withOpacity(0.2),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    task.quizScore! >= 5
                                                        ? Icons.verified
                                                        : Icons.warning_amber,
                                                    size: 10,
                                                    color: task.quizScore! >= 5
                                                        ? AppColors.success
                                                        : Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Quiz: ${task.quizScore}/10',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: task.quizScore! >=
                                                              5
                                                          ? AppColors.success
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz(
      BuildContext context, int weekIndex, int taskIndex) async {
    final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);
    final task = roadmapVM.currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text('Preparing your skill quiz...'),
              ],
            ),
          ),
        ),
      ),
    );

    final questions = await roadmapVM.fetchQuizForTask(weekIndex, taskIndex);
    if (!context.mounted) return;
    Navigator.pop(context); // Close loading
    if (questions.isNotEmpty) {
      final bool? passed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            weekIndex: weekIndex,
            taskIndex: taskIndex,
            topic: task.title,
            questions: questions,
          ),
        ),
      );

      // Only complete if passed
      if (passed == true) {
        if (!context.mounted) return;
        final mainVM = Provider.of<MainViewModel>(context, listen: false);
        await roadmapVM.toggleTaskCompletion(
            weekIndex, taskIndex, true, mainVM.currentUser, mainVM.updateUser);
      }
    }
  }

  void _showResourceSheet(BuildContext context, int weekIndex, int taskIndex) {
    final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);

    // Trigger fetch
    roadmapVM.fetchResourcesForTask(weekIndex, taskIndex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<RoadmapViewModel>(
          builder: (context, vm, child) {
            final task = vm.currentRoadmap!.weeks[weekIndex].tasks[taskIndex];
            final isLoading = task.bestResources == null;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        if (task.quizScore != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Close sheet
                              _startQuiz(context, weekIndex, taskIndex);
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retake Quiz'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        else if (task.isCompleted)
                          const Icon(Icons.check_circle,
                              color: AppColors.success)
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading.rectangular(height: 20, width: 150),
                            SizedBox(height: 16),
                            ShimmerLoading.rectangular(height: 100),
                            SizedBox(height: 24),
                            ShimmerLoading.rectangular(height: 50),
                          ],
                        ),
                      )
                    else ...[
                      const Text('Top Resources',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1)),
                        ),
                        child: SelectableText(
                          task.bestResources!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (task.youtubeQuery != null &&
                          task.youtubeQuery!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            final query =
                                Uri.encodeComponent(task.youtubeQuery!);
                            _launchURL(
                                'https://www.youtube.com/results?search_query=$query');
                          },
                          icon: const Icon(Icons.play_circle_fill,
                              color: Colors.white),
                          label: const Text('Search Tutorials on YouTube'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (task.quizScore == null && !task.isCompleted)
                        GradientButton(
                          text: 'Take Skill Quiz',
                          onPressed: () {
                            Navigator.pop(context); // Close sheet
                            _startQuiz(context, weekIndex, taskIndex);
                          },
                          icon: Icons.quiz_outlined,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString.trim());
      // On Android 11+, canLaunchUrl can be unreliable.
      // It's often better to try launching and handle the error.
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No app found to open this link: $urlString')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}
