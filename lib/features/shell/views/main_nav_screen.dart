import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
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
    AnnouncementsScreen(),
    NewsListScreen(),
    PoliciesScreen(),
    DocumentsScreen(),
  ];

  final List<String> _titles = [
    'Digital Portal',
    'Announcements Feed',
    'News & Articles',
    'Organizational Policies',
    'Document Library',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        const SizedBox(width: 4),
      ],
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
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          final unreadCount = state.unreadCount;

          return NavigationBar(
            elevation: 0,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryContainer,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Icon(Icons.campaign_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: AppColors.primary),
                ),
                label: 'Feed',
              ),
              const NavigationDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper_rounded, color: AppColors.primary),
                label: 'News',
              ),
              const NavigationDestination(
                icon: Icon(Icons.policy_outlined),
                selectedIcon: Icon(Icons.policy_rounded, color: AppColors.primary),
                label: 'Policies',
              ),
              const NavigationDestination(
                icon: Icon(Icons.folder_open_outlined),
                selectedIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
                label: 'Documents',
              ),
            ],
          );
        },
      ),
    );
  }
}
