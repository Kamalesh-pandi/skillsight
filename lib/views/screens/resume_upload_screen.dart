import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/skill_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'skill_extraction_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  File? _selectedFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  void _uploadAndProcess() async {
    if (_selectedFile == null) return;

    final skillVM = Provider.of<SkillViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await skillVM.processResume(user.uid, _selectedFile!);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SkillExtractionScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          final error = skillVM.errorMessage ?? e.toString();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Processing Error'),
                    content: Text(error),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillVM = context.watch<SkillViewModel>();

    return Scaffold(
      appBar: const GradientAppBar(title: 'Upload Resume'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description,
                  size: 100,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[300]),
              const SizedBox(height: 24),
              const Text(
                'Upload your PDF resume to analyze your skills using SkillSight AI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_selectedFile != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_selectedFile!.path.split('/').last,
                              overflow: TextOverflow.ellipsis)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _selectedFile = null)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              //GradientButton
              GradientButton(
                text: 'Select PDF',
                onPressed: skillVM.isProcessing ? null : _pickFile,
                isLoading: skillVM.isProcessing,
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                GradientButton(
                  text: 'Analyze Resume',
                  onPressed: skillVM.isProcessing ? null : _uploadAndProcess,
                  isLoading: skillVM.isProcessing,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
