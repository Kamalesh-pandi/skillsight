import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../constants/app_theme.dart';
import 'profile_setup_screen.dart';
import 'resume_upload_screen.dart';
import 'career_goal_screen.dart';
import 'roadmap_screen.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';
import 'mentor_chat_screen.dart'; // Added Chat Screen
import '../widgets/gradient_app_bar.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context);
    final user = mainVM.currentUser;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'SkillSight AI',
        leading: user != null
            ? Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen())),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.whatshot,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 2),
                      Text(
                        '${user.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
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
            // User Header with Gradient and Shadow
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
            // Points & Leaderboard Summary Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.emoji_events_rounded,
                      label: 'Leaderboard',
                      value: 'View Rank',
                      color: Colors.pink,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen())),
                    ),
                  ],
                ),
              ),
            ),

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
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
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
}
