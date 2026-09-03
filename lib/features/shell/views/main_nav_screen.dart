import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../announcements/view_model/announcements_bloc.dart';
import '../../announcements/view_model/announcements_state.dart';
import '../../announcements/views/announcements_screen.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../../auth/view_model/auth_bloc.dart';
import '../../auth/view_model/auth_event.dart';
import '../../auth/view_model/auth_state.dart';
import '../../documents/views/documents_screen.dart';
import '../../home/views/home_screen.dart';
import '../../news/views/news_list_screen.dart';
import '../../policies/views/policies_screen.dart';
import '../widgets/cms_demo_dialog.dart';

/// Main Shell Screen managing the 5 Dynamic Tabs
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    NewsListScreen(),
    PoliciesScreen(),
    DocumentsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Content Management',
    'Analytics & Insights',
    'Administration & System',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) {
      return AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF111827)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF003D99)),
            onPressed: () {
              UIHelpers.showSnackBar(context, 'No new system notifications.');
            },
          ),
          IconButton(
            tooltip: 'User Profile & Session',
            icon: const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFFE5E7EB),
              child: Icon(Icons.person, color: Color(0xFF6B7280), size: 18),
            ),
            onPressed: () => _showProfileDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IDEALAKE • LTFS',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _titles[_currentIndex],
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sitefinity CMS Simulator',
          icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
          onPressed: () => CmsDemoDialog.show(context),
        ),
        IconButton(
          tooltip: 'User Profile & Session',
          icon: const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => _showProfileDialog(context),
        ),
        IconButton(
          tooltip: 'Sign Out',
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          onPressed: () => _showLogoutConfirmationDialog(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0D3C89),
              width: double.infinity,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF0D3C89), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Sitefinity 14.1 CMS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.grid_view_rounded, color: Color(0xFF003D99)),
                    title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Content'),
                    selected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_rounded),
                    title: const Text('Analytics'),
                    selected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Admin'),
                    selected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: const Text('Announcements Feed'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
                    title: const Text('Sitefinity CMS Simulator'),
                    onTap: () {
                      Navigator.pop(context);
                      CmsDemoDialog.show(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutConfirmationDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.currentUser ??
                locator<AuthRepository>().getCurrentUser() ??
                const UserModel(
                  id: 'usr-101',
                  fullName: 'Rakesh Sunar',
                  email: 'rakesh.sunar@idealake.com',
                  role: 'Technical Lead / CMS Admin',
                  department: 'Digital Solutions - LTFS',
                );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              user.role,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Active Session Details',
                  style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Department:', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    Text(user.department ?? 'LTFS Digital Architecture', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Auth Provider:', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    Text('Sitefinity Headless JWT', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Sign Out Session',
                  buttonType: ButtonType.outlined,
                  prefixIcon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  textColor: AppColors.error,
                  onPressed: () => _handleLogout(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 1. Dispatch AuthLogoutRequested to trigger BLoC state reset
    context.read<AuthBloc>().add(AuthLogoutRequested());

    // 2. Explicitly wipe all tokens and session data from SharedPreferences
    await locator<AuthRepository>().clearToken();

    // 3. Clear entire navigation history and navigate directly to Login
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out? Your authentication token and session will be cleared.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _handleLogout(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: NavigationBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF9FAFB),
        indicatorColor: const Color(0xFF004FC7),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, color: Color(0xFF4B5563)),
            selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined, color: Color(0xFF4B5563)),
            selectedIcon: Icon(Icons.description_rounded, color: Colors.white),
            label: 'Content',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_rounded, color: Color(0xFF4B5563)),
            selectedIcon: Icon(Icons.insights_rounded, color: Colors.white),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Color(0xFF4B5563)),
            selectedIcon: Icon(Icons.settings_rounded, color: Colors.white),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
