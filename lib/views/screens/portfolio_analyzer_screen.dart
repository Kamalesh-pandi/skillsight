import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../constants/app_theme.dart';
import '../../viewmodels/portfolio_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../widgets/gradient_app_bar.dart';

class PortfolioAnalyzerScreen extends StatefulWidget {
  const PortfolioAnalyzerScreen({super.key});

  @override
  State<PortfolioAnalyzerScreen> createState() =>
      _PortfolioAnalyzerScreenState();
}

class _PortfolioAnalyzerScreenState extends State<PortfolioAnalyzerScreen> {
  final TextEditingController _urlController = TextEditingController();

  void _analyze() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a GitHub URL')),
      );
      return;
    }

    final mainVM = Provider.of<MainViewModel>(context, listen: false);
    final careerGoal = mainVM.currentUser?.careerGoal ?? 'Software Developer';

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    Provider.of<PortfolioViewModel>(context, listen: false)
        .analyzePortfolio(url, careerGoal);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = Provider.of<PortfolioViewModel>(context);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Portfolio Analyzer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(isDark),
            const SizedBox(height: 24),
            if (vm.isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing Repository...'),
                    Text('This may take a moment to read the code & docs.'),
                  ],
                ),
              )
            else if (vm.error != null)
              Center(
                child: Text(
                  'Error: ${vm.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else if (vm.analysis != null)
              _buildResults(vm, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyze Your GitHub Repo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste a link to your public GitHub repository to get detailed feedback on code quality, complexity, and job relevance.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'https://github.com/username/repo',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _analyze(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Analyze Repository'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(PortfolioViewModel vm, bool isDark) {
    final analysis = vm.analysis!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Text(
          'Analysis Results',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),

        // Scores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreCircle(
              context,
              'Code\nQuality',
              analysis.codeQualityScore,
              AppColors.primary,
            ),
            _buildScoreCircle(
              context,
              'Complexity',
              analysis.projectComplexityScore,
              AppColors.secondary,
            ),
            _buildScoreCircle(
              context,
              'Relevance',
              analysis.jobRelevanceScore,
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Summary
        _buildSectionTitle(context, 'Summary'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Text(
            analysis.analysisSummary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Suggestions
        _buildSectionTitle(context, 'Suggestions for Improvement'),
        ...analysis.suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildScoreCircle(
      BuildContext context, String label, int score, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 8.0,
          percent: score / 100,
          center: Text(
            "$score%",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
