import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../constants/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class QuizScreen extends StatefulWidget {
  final int weekIndex;
  final int taskIndex;
  final String topic;
  final List<Map<String, dynamic>> questions;

  const QuizScreen({
    super.key,
    required this.weekIndex,
    required this.taskIndex,
    required this.topic,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  bool _isQuizFinished = false;

  void _submitAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = index;
      _isAnswered = true;
      if (index == widget.questions[_currentIndex]['correctIndex']) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < widget.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _isAnswered = false;
        });
      } else {
        setState(() {
          _isQuizFinished = true;
        });
        // Save score to ViewModel
        final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);
        roadmapVM.saveQuizScore(widget.weekIndex, widget.taskIndex, _score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizFinished) {
      return _buildResultScreen();
    }

    final question = widget.questions[_currentIndex];
    final options = question['options'] as List;

    return Scaffold(
      appBar: GradientAppBar(
        title: '${widget.topic} Quiz',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              backgroundColor: Theme.of(context).dividerColor,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${_currentIndex + 1} of ${widget.questions.length}',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text(
              question['question'],
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 32),
            ...List.generate(options.length, (index) {
              return _buildOptionCard(
                  index, options[index], question['correctIndex']);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, String text, int correctIndex) {
    Color cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    Color borderColor = Theme.of(context).dividerColor.withOpacity(0.1);
    IconData? icon;

    if (_isAnswered) {
      if (index == correctIndex) {
        cardColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (index == _selectedOption) {
        cardColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (_selectedOption == index) {
      borderColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _submitAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              if (!_isAnswered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _selectedOption == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _isAnswered && index == correctIndex
                        ? Colors.green[800]
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon,
                    color:
                        icon == Icons.check_circle ? Colors.green : Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final bool passed = _score >= 5;
    final double percentage = _score / widget.questions.length;

    String feedback;
    IconData feedbackIcon;
    Color feedbackColor;

    if (_score >= 9) {
      feedback = 'Outstanding Master!';
      feedbackIcon = Icons.workspace_premium;
      feedbackColor = Colors.amber;
    } else if (_score >= 7) {
      feedback = 'Great Job! Proficient';
      feedbackIcon = Icons.sentiment_very_satisfied;
      feedbackColor = Colors.green;
    } else if (passed) {
      feedback = 'Well Done! Passed';
      feedbackIcon = Icons.check_circle_outline;
      feedbackColor = AppColors.primary;
    } else {
      feedback = 'Keep Practicing!';
      feedbackIcon = Icons.refresh;
      feedbackColor = Colors.red;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              feedbackColor.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Score Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 12,
                        backgroundColor: feedbackColor.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(feedbackColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_score',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: feedbackColor,
                          ),
                        ),
                        Text(
                          'out of ${widget.questions.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Icon(feedbackIcon, size: 48, color: feedbackColor),
                const SizedBox(height: 16),
                Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (!passed)
                  Text(
                    'Score at least 5/${widget.questions.length} to master this topic.',
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: feedbackColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildStatItem('Correct', '$_score', Colors.green),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      _buildStatItem(
                        'Incorrect',
                        '${widget.questions.length - _score}',
                        Colors.red,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                      _buildStatItem(
                        'Skills',
                        '${(percentage * 100).toInt()}%',
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: passed ? 'Back to Roadmap' : 'Try Again Later',
                  onPressed: () => Navigator.pop(context, passed),
                  icon: passed ? Icons.arrow_back : Icons.history_edu_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
