import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillsight/views/widgets/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/gradient_app_bar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final String _targetEmail = 'kamaleshpandi124@gmail.com';

  Future<void> _sendFeedback() async {
    final String subject = _subjectController.text.trim();
    final String body = _messageController.text.trim();

    if (subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in both subject and message')),
      );
      return;
    }

    final String urlString =
        'mailto:$_targetEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    final Uri emailLaunchUri = Uri.parse(urlString);

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched && mounted) {
        Navigator.pop(context);
      } else {
        throw 'No email app found';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Could not open email app. Please email $_targetEmail directly.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Copy Email',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _targetEmail));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard!')),
                  );
                }
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Share Feedback',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us what you think!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve SkillSight AI for everyone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Bug report, Feature request...',
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Explain your feedback in detail...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            //GradientButton
            GradientButton(
              text: 'Send Feedback',
              onPressed: _sendFeedback,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Sends to: $_targetEmail',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
