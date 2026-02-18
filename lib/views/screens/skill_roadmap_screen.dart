import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/skill_roadmap_viewmodel.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/webview_screen.dart';
import '../../models/roadmap_model.dart';
import '../../constants/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';
import 'quiz_screen.dart';
import 'interview_prep_screen.dart';
import '../widgets/shimmer_loading.dart';

class SkillRoadmapScreen extends StatefulWidget {
  final String skillName;
  final Color skillColor;

  const SkillRoadmapScreen({
    super.key,
    required this.skillName,
    required this.skillColor,
  });

  @override
  State<SkillRoadmapScreen> createState() => _SkillRoadmapScreenState();
}

class _SkillRoadmapScreenState extends State<SkillRoadmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<SkillRoadmapViewModel>(context, listen: false)
          .generateSkillRoadmap(widget.skillName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SkillRoadmapViewModel>();
    final roadmap = vm.currentRoadmap;

    if (vm.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.skillColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Generating ${widget.skillName} Roadmap...',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (roadmap == null) {
      if (vm.errorMessage != null) {
        return Scaffold(
          appBar: GradientAppBar(title: 'Mastering ${widget.skillName}'),
          body: Center(child: Text(vm.errorMessage!)),
        );
      }
      return const Scaffold(
          body: Center(child: Text('Could not generate roadmap')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, vm),
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
                    vm,
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

  Widget _buildSliverAppBar(BuildContext context, SkillRoadmapViewModel vm) {
    return SliverAppBar(
      expandedHeight: 240, // Match main roadmap height
      pinned: true,
      stretch: true,
      backgroundColor: widget.skillColor,
      centerTitle: true,
      title: Text('Mastering ${widget.skillName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            vm.generateSkillRoadmap(widget.skillName);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.skillColor, widget.skillColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
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
                      const SizedBox(height: 20),
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
          const Icon(Icons.code, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    RoadmapWeek week,
    int weekIndex,
    SkillRoadmapViewModel vm,
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
                        : widget.skillColor.withOpacity(0.5),
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
                          style: TextStyle(
                            color: widget.skillColor,
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
                      color: widget.skillColor.withOpacity(0.2),
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
                            : widget.skillColor.withOpacity(0.05),
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
                                : widget.skillColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Week ${week.weekNumber}: ${week.focus}',
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
                                  vertical: 8, horizontal: 8),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (!task.isCompleted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Take the quiz to complete this task!'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      } else {
                                        // Allow unchecking manually if needed, or we can block this too.
                                        // "checked only when they pass" implies the check act is restricted.
                                        // Let's allow unchecking for now in case of manual reset.
                                        vm.toggleTaskCompletion(
                                            weekIndex, taskIndex, false);
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
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.isCompleted
                                            ? AppColors.textSecondary
                                                .withOpacity(0.5)
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                        fontSize: 14,
                                      ),
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

  void _showResourceSheet(BuildContext context, int weekIndex, int taskIndex) {
    // Capture the parent context (SkillRoadmapScreen) to use for navigation/dialogs
    // after the sheet is popped.
    final parentContext = context;

    // We need to capture the VM *before* showing the bottom sheet
    // and pass it via ChangeNotifierProvider.value because the sheet is a new route/context.
    final vm = Provider.of<SkillRoadmapViewModel>(context, listen: false);

    vm.fetchResourcesForTask(weekIndex, taskIndex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: vm,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Consumer<SkillRoadmapViewModel>(
              builder: (context, vm, child) {
                final task =
                    vm.currentRoadmap!.weeks[weekIndex].tasks[taskIndex];

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          children: [
                            Text(
                              task.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            if (task.bestResources == null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerLoading.rectangular(
                                        height: 20, width: 150),
                                    SizedBox(height: 16),
                                    ShimmerLoading.rectangular(height: 120),
                                    SizedBox(height: 24),
                                    ShimmerLoading.rectangular(height: 50),
                                    SizedBox(height: 16),
                                    ShimmerLoading.rectangular(height: 50),
                                  ],
                                ),
                              )
                            ] else ...[
                              _buildResourceSection(context, task),
                              const SizedBox(height: 32),
                              GradientButton(
                                text: 'Take Quiz',
                                icon: Icons.quiz_outlined,
                                onPressed: () async {
                                  // Close sheet
                                  Navigator.pop(context);

                                  // Show loading dialog using PARENT context
                                  if (!parentContext.mounted) return;
                                  showDialog(
                                    context: parentContext,
                                    barrierDismissible: false,
                                    builder: (dialogContext) => const Center(
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Text('Generating quiz...'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  try {
                                    final questions = await vm.fetchQuizForTask(
                                        weekIndex, taskIndex);

                                    if (parentContext.mounted) {
                                      Navigator.pop(
                                          parentContext); // Close loading

                                      if (questions.isEmpty) {
                                        ScaffoldMessenger.of(parentContext)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not generate quiz. Try again.')),
                                        );
                                        return;
                                      }

                                      final result = await Navigator.push<bool>(
                                        parentContext,
                                        MaterialPageRoute(
                                          builder: (_) => QuizScreen(
                                            topic: vm
                                                .currentRoadmap!
                                                .weeks[weekIndex]
                                                .tasks[taskIndex]
                                                .title,
                                            questions: questions,
                                          ),
                                        ),
                                      );

                                      if (parentContext.mounted &&
                                          result == true) {
                                        vm.toggleTaskCompletion(
                                            weekIndex, taskIndex, true);
                                        ScaffoldMessenger.of(parentContext)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Quiz Passed! Task marked as completed.')),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (parentContext.mounted) {
                                      Navigator.pop(
                                          parentContext); // Close loading
                                      ScaffoldMessenger.of(parentContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              GradientButton(
                                text: 'Interview Preparation',
                                icon: Icons.work_outline,
                                onPressed: () async {
                                  // Close sheet using the sheet's context
                                  Navigator.pop(context);

                                  // Show loading dialog using PARENT context
                                  if (!parentContext.mounted) return;
                                  showDialog(
                                    context: parentContext,
                                    barrierDismissible: false,
                                    builder: (dialogContext) => const Center(
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                  'Generating interview questions...'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  try {
                                    await vm
                                        .fetchInterviewQuestions(
                                            weekIndex, taskIndex)
                                        .timeout(const Duration(seconds: 60));

                                    if (parentContext.mounted) {
                                      Navigator.pop(
                                          parentContext); // Close loading

                                      final updatedTask = vm.currentRoadmap!
                                          .weeks[weekIndex].tasks[taskIndex];

                                      Navigator.push(
                                        parentContext,
                                        MaterialPageRoute(
                                          builder: (_) => InterviewPrepScreen(
                                            task: updatedTask,
                                            weekIndex: weekIndex,
                                            taskIndex: taskIndex,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (parentContext.mounted) {
                                      Navigator.pop(
                                          parentContext); // Close loading
                                      ScaffoldMessenger.of(parentContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to load questions: ${e.toString()}')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildResourceSection(BuildContext context, RoadmapTask task) {
    if (task.bestResources == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading.rectangular(height: 20, width: 150),
            SizedBox(height: 16),
            ShimmerLoading.rectangular(height: 120),
            SizedBox(height: 24),
            ShimmerLoading.rectangular(height: 50),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Resources',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: MarkdownBody(
            data: task.bestResources!,
            onTapLink: (text, href, title) {
              if (href != null) {
                _launchURL(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        if (task.youtubeQuery != null && task.youtubeQuery!.isNotEmpty) ...[
          const SizedBox(height: 24),
          GradientButton(
            text: 'Search Tutorials on YouTube',
            onPressed: () {
              final query = Uri.encodeComponent(task.youtubeQuery!);
              _launchURL('https://www.youtube.com/results?search_query=$query');
            },
            icon: Icons.play_circle_fill,
          ),
        ],
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    // Basic url launch logic - you might need url_launcher package
    // Since RoadmapScreen has it, assuming package is present.
    // For now using a placeholder or basic print if package not imported.
    // Ideally use: await launchUrl(Uri.parse(url));
    // Checking RoadmapScreen imports... it uses `webview_screen.dart`?
    // Let's implement a simple logic or use webview if available.
    // RoadmapScreen uses `url_launcher` implicitly or a utility?
    // Wait, RoadmapScreen has `_launchURL` but I didn't see the implementation in the snippet.
    // It's likely using `url_launcher` or `WebViewScreen`.
    // Let's just use `debugPrint` for now and ask user or check `_launchURL` in RoadmapScreen again if needed.
    // Actually, I can use the existing `WebViewScreen` if available.
    // Let's use `WebViewScreen` since I saw it imported in `RoadmapScreen`.
    // I need to import it here too.

    // For now, let's just print to console to emulate behavior or try to launch if I add the import.
    // I will add WebViewScreen import.

    // Note: I will need to add `import '../widgets/webview_screen.dart';` to imports.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(url: url, title: 'Resource'),
      ),
    );
  }

  void _showQuizDialog(BuildContext context, SkillRoadmapViewModel vm,
      int weekIndex, int taskIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Knowledge Check'),
        content: const Text('Ready to test your knowledge on this topic?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later')),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                // Loading snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating quiz...')),
                );

                final questions =
                    await vm.fetchQuizForTask(weekIndex, taskIndex);

                if (!context.mounted) return;

                if (questions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not generate quiz. Try again.')),
                  );
                  return;
                }

                // Navigate to QuizScreen
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      topic: vm.currentRoadmap!.weeks[weekIndex]
                          .tasks[taskIndex].title,
                      questions: questions,
                      // Do not pass weekIndex/taskIndex to prevent saving to main roadmap
                    ),
                  ),
                );

                if (context.mounted && result == true) {
                  // Quiz Passed
                  vm.toggleTaskCompletion(weekIndex, taskIndex, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Quiz Passed! Task marked as completed.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.skillColor,
                  foregroundColor: Colors.white),
              child: const Text('Start Quiz')),
        ],
      ),
    );
  }
}
