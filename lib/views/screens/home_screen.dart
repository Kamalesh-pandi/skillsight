import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../models/daily_micro_task_model.dart';
import '../../constants/app_theme.dart';
import 'profile_setup_screen.dart';
import 'resume_upload_screen.dart';
import 'career_goal_screen.dart';
import 'roadmap_screen.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';
import 'mentor_chat_screen.dart';
import '../widgets/gradient_app_bar.dart';
import 'leaderboard_screen.dart';
import 'aptitude_screen.dart';
import 'industry_demand_screen.dart';
import 'project_generator_screen.dart';
import 'portfolio_analyzer_screen.dart';
import 'course_recommender_screen.dart';
import '../../data/programming_languages_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'skill_roadmap_screen.dart';
import 'future_you_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final mainVM = Provider.of<MainViewModel>(context, listen: false);
      final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);

      if (mainVM.currentUser != null) {
        if (roadmapVM.currentRoadmap == null) {
          await roadmapVM.fetchRoadmap(mainVM.currentUser!.uid);
        }
        await roadmapVM.loadTodayMicroTasks(
          careerGoalOverride: mainVM.currentUser!.careerGoal,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context);
    final roadmapVM = Provider.of<RoadmapViewModel>(context);
    final user = mainVM.currentUser;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'SkillSight AI',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              final roadmapVM =
                  Provider.of<RoadmapViewModel>(context, listen: false);
              final navigator = Navigator.of(context);

              await authVM.logout();
              mainVM.onUserChanged(null);

              roadmapVM.clear();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (User Header and Stats remain same) ...
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? const Icon(Icons.person,
                              size: 32, color: AppColors.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user?.displayName ?? "Learner",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            user?.careerGoal ?? 'Set your goal',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileSetupScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Points, Rank & Streak Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.stars_rounded,
                      label: 'Points',
                      value: '${user?.points ?? 0}',
                      color: Colors.amber,
                    ),
                    _buildDivider(context),
                    _buildStatItem(
                      context,
                      icon: Icons.emoji_events_rounded,
                      label: 'Rank',
                      value: mainVM.userRank > 0 ? '#${mainVM.userRank}' : '--',
                      color: Colors.pink,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen())),
                    ),
                    _buildDivider(context),
                    _buildStatItem(
                      context,
                      icon: Icons.whatshot,
                      label: 'Streak',
                      value: '${user?.effectiveStreak ?? 0}',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen())),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDailyMicroTasksSection(context, roadmapVM),
            ),

            const SizedBox(height: 24),
            // --- NEW: Programming Languages Learning Section ---
            _buildProgrammingLanguagesSection(context),
            // ------------------------------------------------

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Unlock Your Potential',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),

            // Modern Action Cards
            // ... (rest of the body)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // AI Mentor Card (Top Feature)
                  _buildModernActionCard(
                    context,
                    title: 'AI Career Mentor',
                    subtitle: 'Chat with your personal AI career coach',
                    icon: Icons.auto_awesome,
                    color: Colors.amber,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MentorChatScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Market Demand Analyzer',
                    subtitle: 'Real-time industry trends & skill gaps',
                    icon: Icons.trending_up,
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IndustryDemandScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Personalized Project Generator',
                    subtitle: 'AI suggests portfolio projects for your goals',
                    icon: Icons.rocket_launch_outlined,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProjectGeneratorScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Portfolio Code Analyzer',
                    subtitle: 'AI reviews your GitHub repo code & docs',
                    icon: Icons.code_rounded,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PortfolioAnalyzerScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Strategic Skill Gap Analysis',
                    subtitle: 'Upload resume to identify what\'s missing',
                    icon: Icons.analytics_outlined,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ResumeUploadScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Precision Career Mapping',
                    subtitle: 'Define your destination & required skills',
                    icon: Icons.track_changes_sharp,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CareerGoalScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: '"Future You" Simulator',
                    subtitle: 'Visualize your 5-year career trajectory',
                    icon: Icons.timeline,
                    color: Colors.cyan,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FutureYouScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Course Recommendations',
                    subtitle: 'Find top free & paid courses for your goal',
                    icon: Icons.school_rounded,
                    color: Colors.indigoAccent,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CourseRecommenderScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Personalized Roadmap',
                    subtitle: 'Follow your custom week-by-week plan',
                    icon: Icons.map_rounded,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RoadmapScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Aptitude Course',
                    subtitle: 'Master Quant, Verbal & Logical Reasoning',
                    icon: Icons.calculate_outlined,
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AptitudeScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Leaderboard',
                    subtitle: 'See how you rank against others',
                    icon: Icons.emoji_events_outlined,
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen())),
                  ),
                  _buildModernActionCard(
                    context,
                    title: 'Share Feedback',
                    subtitle: 'Help us improve your experience',
                    icon: Icons.feedback_outlined,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FeedbackScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ... (previous helper methods)

  Widget _buildProgrammingLanguagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learn Programming',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Optional: View All button if needed
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: allProgrammingLanguages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final lang = allProgrammingLanguages[index];
              return _buildLanguageCard(context, lang);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(
      BuildContext context, ProgrammingLanguageModel lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SkillRoadmapScreen(
              skillName: lang.name,
              skillColor: lang.color,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: SvgPicture.network(
                  lang.logoUrl,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(lang.color),
                    ),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lang.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Keep existing methods below...

  Widget _buildDailyMicroTasksSection(
      BuildContext context, RoadmapViewModel vm) {
    // Show only the top 2 tasks on home to keep it compact
    final tasks = vm.todayMicroTasks.take(2).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Micro-Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (vm.isLoadingDailyTasks)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Preparing today\'s 10–20 min tasks...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else if (vm.dailyTasksError != null)
              Text(
                vm.dailyTasksError!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                ),
              )
            else if (tasks.isEmpty)
              const SizedBox.shrink()
            else ...[
              Column(
                children: tasks.map((task) {
                  final statusColor = switch (task.status) {
                    DailyMicroTaskStatus.done => AppColors.success,
                    DailyMicroTaskStatus.skipped => Colors.orange,
                    DailyMicroTaskStatus.inProgress => AppColors.primary,
                    DailyMicroTaskStatus.pending =>
                      AppColors.textSecondary.withOpacity(0.7),
                  };

                  final statusLabel = switch (task.status) {
                    DailyMicroTaskStatus.done => 'Done',
                    DailyMicroTaskStatus.skipped => 'Skipped',
                    DailyMicroTaskStatus.inProgress => 'In progress',
                    DailyMicroTaskStatus.pending => 'Not started',
                  };

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6, right: 8),
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  // On home, keep description minimal (one line max)
                                  if (task.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        task.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timelapse,
                                              size: 12,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${task.durationMinutes} min',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: statusColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (task.skillTag.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .chipTheme
                                                  .backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.tag,
                                                  size: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    task.skillTag,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.4),
                                          ),
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          vm.updateDailyTaskStatus(
                                            task.id,
                                            task.status ==
                                                    DailyMicroTaskStatus.done
                                                ? DailyMicroTaskStatus.pending
                                                : DailyMicroTaskStatus.done,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          task.status ==
                                                  DailyMicroTaskStatus.done
                                              ? 'Undo'
                                              : 'Done',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          vm.updateDailyTaskStatus(
                                            task.id,
                                            task.status ==
                                                    DailyMicroTaskStatus.skipped
                                                ? DailyMicroTaskStatus.pending
                                                : DailyMicroTaskStatus.skipped,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          task.status ==
                                                  DailyMicroTaskStatus.skipped
                                              ? 'Unskip'
                                              : 'Skip',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoadmapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, size: 16),
                  label: const Text(
                    'View all micro-tasks',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color color,
      VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }
}
