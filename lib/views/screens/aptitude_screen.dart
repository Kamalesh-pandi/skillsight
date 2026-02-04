import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';
import 'quiz_screen.dart';
import '../../services/ai_service.dart';

class AptitudeScreen extends StatelessWidget {
  const AptitudeScreen({super.key});

  final Map<String, List<String>> topics = const {
    "Quantitative Aptitude": [
      "Number System",
      "HCF & LCM",
      "Percentage",
      "Profit & Loss",
      "Simple & Compound Interest",
      "Ratio & Proportion",
      "Time & Work",
      "Pipes & Cisterns",
      "Time, Speed & Distance",
      "Boats & Streams",
      "Permutation & Combination",
      "Probability",
      "Mensuration"
    ],
    "Logical Reasoning": [
      "Number Series",
      "Letter Series",
      "Coding-Decoding",
      "Blood Relations",
      "Direction Sense",
      "Seating Arrangement",
      "Syllogism",
      "Clocks & Calendars",
      "Data Interpretation"
    ],
    "Verbal Ability": [
      "Reading Comprehension",
      "Synonyms & Antonyms",
      "Sentence Correction",
      "Spotting Errors",
      "Para Jumbles",
      "Idioms & Phrases"
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Aptitude Prep'),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: topics.keys.length,
        itemBuilder: (context, index) {
          String category = topics.keys.elementAt(index);
          List<String> subTopics = topics[category]!;

          return _buildCategoryCard(context, category, subTopics);
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String title, List<String> subTopics) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_outlined, color: AppColors.primary),
          ),
          children: subTopics.map((topic) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(topic, style: const TextStyle(fontSize: 15)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _startQuiz(context, topic),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _startQuiz(BuildContext context, String topic) async {
    // Show loading dialog
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16),
                Text('Generating aptitude quiz...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final aiService = AIService();
      // Use 'General Aptitude' as career goal for context
      final questions = await aiService
          .generateQuiz(topic, "General Aptitude")
          .timeout(const Duration(seconds: 45));

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        if (questions.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                topic: topic,
                questions: questions,
                // weekIndex and taskIndex are null, so no roadmap update
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to generate questions. Try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
