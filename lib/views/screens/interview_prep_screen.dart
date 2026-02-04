import 'package:flutter/material.dart';
import '../../models/roadmap_model.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';
import '../../constants/app_theme.dart';

class InterviewPrepScreen extends StatefulWidget {
  final RoadmapTask task;
  final int weekIndex;
  final int taskIndex;

  const InterviewPrepScreen({
    super.key,
    required this.task,
    required this.weekIndex,
    required this.taskIndex,
  });

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showAnswer = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < (widget.task.interviewQuestions?.length ?? 0) - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _showAnswer = false);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _showAnswer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.task.interviewQuestions ?? [];
    final total = questions.length;
    final progress = total > 0 ? (_currentPage + 1) / total : 0.0;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Interview Preparation',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentPage + 1} / $total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No questions generated yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() {
                      _currentPage = page;
                      _showAnswer = false;
                    }),
                    itemCount: total,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return _buildFlashcard(context, q);
                    },
                  ),
                ),
                _buildControls(),
              ],
            ),
    );
  }

  Widget _buildFlashcard(BuildContext context, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(Tween(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              )),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey('card_${_currentPage}_$_showAnswer'),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _showAnswer ? 'SUGGESTED ANSWER' : 'INTERVIEW QUESTION',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showAnswer
                        ? Text(
                            data['answer'] ?? 'No answer provided.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          )
                        : Text(
                            data['question'] ?? 'No question provided.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: _showAnswer ? 'Hide Answer' : 'Show Answer',
                onPressed: () => setState(() => _showAnswer = !_showAnswer),
                icon: _showAnswer ? Icons.visibility_off : Icons.visibility,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final total = widget.task.interviewQuestions?.length ?? 0;
    final isLast = _currentPage == total - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isLast
                ? GradientButton(
                    text: 'Finish',
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.check_circle,
                  )
                : GradientButton(
                    text: 'Next',
                    onPressed: _nextPage,
                    icon: Icons.arrow_forward,
                  ),
          ),
        ],
      ),
    );
  }
}
