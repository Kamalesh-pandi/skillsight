import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/skill_viewmodel.dart';
import '../../models/career_role_model.dart';
import '../../constants/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../../utils/icon_mapper.dart';
import 'skill_gap_analyzer_screen.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/gradient_button.dart';

class CareerGoalScreen extends StatefulWidget {
  const CareerGoalScreen({super.key});

  @override
  State<CareerGoalScreen> createState() => _CareerGoalScreenState();
}

class _CareerGoalScreenState extends State<CareerGoalScreen> {
  CareerRoleModel? _selectedRole;
  bool _initialized = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final skillVM = Provider.of<SkillViewModel>(context, listen: false);
      final mainVM = Provider.of<MainViewModel>(context, listen: false);

      if (skillVM.suggestedGoal != null && mainVM.roles.isNotEmpty) {
        final suggested = skillVM.suggestedGoal!.toLowerCase();

        try {
          _selectedRole = mainVM.roles.firstWhere(
            (r) =>
                suggested.contains(r.title.toLowerCase()) ||
                r.title.toLowerCase().contains(suggested),
          );
        } catch (_) {
          // No match found
        }
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainVM = context.watch<MainViewModel>();
    final allRoles = mainVM.roles;

    // Filter roles based on search query
    final filteredRoles = _searchQuery.isEmpty
        ? allRoles
        : allRoles.where((role) {
            final query = _searchQuery.toLowerCase();
            return role.title.toLowerCase().contains(query) ||
                role.category.toLowerCase().contains(query);
          }).toList();

    // Group roles by category
    final groupedRoles = <String, List<CareerRoleModel>>{};
    for (var role in filteredRoles) {
      groupedRoles.putIfAbsent(role.category, () => []).add(role);
    }

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Career Goal',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: mainVM.isRolesLoading
          ? const ShimmerList()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Choose your path',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select the role you want to master',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search roles (e.g., Python, Solar)...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: groupedRoles.length,
                    itemBuilder: (context, index) {
                      final category = groupedRoles.keys.elementAt(index);
                      final categoryRoles = groupedRoles[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          ...categoryRoles.map((role) {
                            bool isSelected = _selectedRole?.id == role.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedRole = role),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.05)
                                        : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.primary
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          IconMapper.getIcon(role.iconCode),
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              role.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              role.description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                        ),
                                    ],
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
                if (_selectedRole != null)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GradientButton(
                      text: 'Continue',
                      onPressed: () {
                        context
                            .read<MainViewModel>()
                            .selectCareerGoal(_selectedRole!.title);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SkillGapAnalyzerScreen(
                                  selectedRole: _selectedRole!)),
                        );
                      },
                      icon: Icons.arrow_forward,
                    ),
                  ),
              ],
            ),
    );
  }
}
