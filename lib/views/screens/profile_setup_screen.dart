import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/user_model.dart';
import '../../constants/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../../utils/icon_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _educationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _skillController = TextEditingController();
  String? _selectedGoal;
  List<String> _manualSkills = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<MainViewModel>(context, listen: false).currentUser;
    if (user != null) {
      _educationController.text = user.education ?? '';
      _departmentController.text = user.department ?? '';
      _selectedGoal = user.careerGoal;
      _manualSkills = List.from(user.manualSkills);
    }
  }

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_manualSkills.contains(skill)) {
      setState(() {
        _manualSkills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _manualSkills.remove(skill);
    });
  }

  void _saveProfile() async {
    final mainVM = Provider.of<MainViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel updatedUser;
      if (mainVM.currentUser != null) {
        updatedUser = mainVM.currentUser!.copyWith(
          education: _educationController.text,
          department: _departmentController.text,
          careerGoal: _selectedGoal,
          manualSkills: _manualSkills,
        );
      } else {
        updatedUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Learner',
          photoUrl: user.photoURL,
          education: _educationController.text,
          department: _departmentController.text,
          careerGoal: _selectedGoal,
          manualSkills: _manualSkills,
        );
      }
      try {
        await mainVM.saveUserProfile(updatedUser);
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save profile: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainVM = context.watch<MainViewModel>();
    final roles = mainVM.roles;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Complete Profile',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator or Header
            Text(
              'Personalize your journey',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us tailor the best learning path for you.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Section: Basic Info
            _buildSectionHeader(
                context, 'Academic Background', Icons.school_outlined),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _educationController,
                    decoration: const InputDecoration(
                      labelText: 'Education',
                      hintText: 'e.g. Engineering',
                      prefixIcon: Icon(Icons.history_edu_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      hintText: 'e.g. Computer Science',
                      prefixIcon: Icon(Icons.layers_outlined),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section: Career Goal
            _buildSectionHeader(
                context, 'Primary Objective', Icons.track_changes_outlined),
            mainVM.isRolesLoading
                ? const ShimmerLoading.rectangular(height: 56)
                : _buildPickerTrigger(
                    context,
                    label: 'Target Career Goal',
                    value: _selectedGoal ?? 'Choose your future role',
                    icon: Icons.stars_outlined,
                    onTap: () {
                      _showSearchablePicker(
                        context,
                        title: 'Select Career Goal',
                        options: roles
                            .map((r) => PickerOption(
                                  label: r.title,
                                  category: r.category,
                                  iconCode: r.iconCode,
                                ))
                            .toList(),
                        onSelected: (option) =>
                            setState(() => _selectedGoal = option.label),
                      );
                    },
                  ),

            const SizedBox(height: 32),

            // Section: Skills
            _buildSectionHeader(
                context, 'Expertise & Tech Stack', Icons.terminal_outlined),
            _buildPickerTrigger(
              context,
              label: 'Add Technical Skills',
              value: 'Select a skill to add',
              icon: Icons.terminal_outlined,
              onTap: () {
                _showSearchablePicker(
                  context,
                  title: 'Select Skill',
                  options: mainVM.allSkills
                      .map((s) => PickerOption(label: s))
                      .toList(),
                  onSelected: (option) => _addSkill(option.label),
                );
              },
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _manualSkills
                  .map((skill) => Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close_rounded, size: 14),
                          onDeleted: () => _removeSkill(skill),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 48),

            GradientButton(
              text: 'Level Up My Profile',
              onPressed: _saveProfile,
              icon: Icons.rocket_launch,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTrigger(BuildContext context,
      {required String label,
      required String value,
      required IconData icon,
      required VoidCallback onTap}) {
    bool isPlaceholder =
        value == 'Choose your future role' || value == 'Select a skill to add';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.primary.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Text(
                    value,
                    style: TextStyle(
                      color: isPlaceholder
                          ? Theme.of(context).hintColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSearchablePicker(BuildContext context,
      {required String title,
      required List<PickerOption> options,
      required Function(PickerOption) onSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchablePicker(
          title: title,
          options: options,
          onSelected: onSelected,
        );
      },
    );
  }
}

class PickerOption {
  final String label;
  final String? category;
  final int? iconCode;

  PickerOption({required this.label, this.category, this.iconCode});
}

class _SearchablePicker extends StatefulWidget {
  final String title;
  final List<PickerOption> options;
  final Function(PickerOption) onSelected;

  const _SearchablePicker({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  late List<PickerOption> _filteredOptions;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_filterOptions);
  }

  void _filterOptions() {
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.label
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group options by category if category exists
    final groupedOptions = <String?, List<PickerOption>>{};
    for (var option in _filteredOptions) {
      groupedOptions.putIfAbsent(option.category, () => []).add(option);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              autofocus:
                  false, // Changed to false to avoid automatic keyboard popup
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredOptions.isEmpty && _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No matching skills found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GradientButton(
                            text: 'Add "${_searchController.text}" manually',
                            onPressed: () {
                              widget.onSelected(
                                  PickerOption(label: _searchController.text));
                              Navigator.pop(context);
                            },
                            icon: Icons.add_rounded,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: groupedOptions.length,
                    itemBuilder: (context, index) {
                      final category = groupedOptions.keys.elementAt(index);
                      final categoryOptions = groupedOptions[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (category != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ...categoryOptions.map((option) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    widget.onSelected(option);
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        if (option.iconCode != null) ...[
                                          Icon(
                                            IconMapper.getIcon(option.iconCode),
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Text(
                                            option.label,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.add_rounded,
                                            size: 20,
                                            color: AppColors.primary
                                                .withOpacity(0.5)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
