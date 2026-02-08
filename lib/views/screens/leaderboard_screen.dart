import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../widgets/gradient_app_bar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<UserModel>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final users = await _dbService.getLeaderboardUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Leaderboard',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users == null || _users!.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No one on the leaderboard yet!'),
          const Text('Be the first to complete a topic.'),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        // Top 3 Players Section (Visual Highlight)
        if (_users!.length >= 3) _buildTopThree(),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users!.length,
            itemBuilder: (context, index) {
              // Calculate rank with tie-handling
              int currentRank = 1;
              for (int i = 0; i < index; i++) {
                if (_users![i].points > _users![index].points) {
                  currentRank++;
                }
              }

              final user = _users![index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRankBadge(currentRank),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: currentRank <= 3
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${user.points} pts',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${user.effectiveStreak}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopThree() {
    // Calculate ranks for potential podium items with tie-handling
    int rank1 = 1;
    int rank2 = 1;
    for (int i = 0; i < 1; i++) {
      if (_users![0].points > _users![1].points) rank2++;
    }
    int rank3 = 1;
    for (int i = 0; i < 2; i++) {
      if (_users![i].points > _users![2].points) rank3++;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(_users![1], rank2, 80), // Position 2
          _buildPodiumItem(_users![0], rank1, 100), // Position 1
          _buildPodiumItem(_users![2], rank3, 80), // Position 3
        ],
      ),
    );
  }

  Widget _buildPodiumItem(UserModel user, int rank, double height) {
    Color medalColor = rank == 1
        ? Colors.amber
        : (rank == 2 ? Colors.grey[400]! : Colors.brown[300]!);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [medalColor, medalColor.withOpacity(0.5)],
                ),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 32,
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
              ),
              child: Text(
                rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.displayName.split(' ')[0],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          '${user.points} pt',
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    Color? textColor;
    double fontSize = 14;
    FontWeight fontWeight = FontWeight.normal;

    if (rank == 1) {
      textColor = Colors.amber[700];
      fontWeight = FontWeight.bold;
      fontSize = 16;
    } else if (rank == 2) {
      textColor = Colors.grey[600];
      fontWeight = FontWeight.bold;
    } else if (rank == 3) {
      textColor = Colors.brown[400];
      fontWeight = FontWeight.bold;
    } else {
      textColor = Colors.grey[500];
    }

    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
