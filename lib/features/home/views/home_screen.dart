import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../view_model/home_bloc.dart';
import '../view_model/home_event.dart';
import '../view_model/home_state.dart';
import '../widgets/awards_carousel_widget.dart';
import '../widgets/banner_carousel_widget.dart';
import '../widgets/clients_logo_strip_widget.dart';
import '../widgets/featured_content_widget.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/service_card_widget.dart';
import '../widgets/tech_pillars_widget.dart';

/// Main Dashboard / Home Screen for Idealake LTFS Portal (100% Dynamic from Sitefinity CMS APIs)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Development', 'Web', 'Fintech', 'Cloud', 'Design'];

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeFetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.bannersResponse.isLoading && state.servicesResponse.isLoading) {
            return const LoadingWidget(message: 'Connecting to Sitefinity Headless CMS...');
          }

          if (state.bannersResponse.isError && state.servicesResponse.isError) {
            return ErrorView(
              message: state.bannersResponse.message,
              onRetry: () {
                context.read<HomeBloc>().add(HomeFetchDataEvent());
              },
            );
          }

          final banners = state.bannersResponse.data ?? [];
          final services = state.servicesResponse.data ?? [];
          final clients = state.clientsResponse.data ?? [];
          final awards = state.awardsResponse.data ?? [];
          final contents = state.contentsResponse.data ?? [];

          final filteredServices = state.selectedCategory == 'All'
              ? services
              : services.where((s) => s.category?.toLowerCase() == state.selectedCategory.toLowerCase()).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeRefreshDataEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // 1. Dynamic Promotional Banners (Sitefinity /images service-banner)
                  BannerCarouselWidget(banners: banners),
                  const SizedBox(height: 16),

                  // 2. Company Metrics
                  const QuickStatsWidget(),
                  const SizedBox(height: 20),

                  // 3. Tech Execution Pillars (We Design, Develop, Deliver)
                  const TechPillarsWidget(),
                  const SizedBox(height: 20),

                  // 4. Dynamic Enterprise Clients Strip (Sitefinity /images ParentId client)
                  if (clients.isNotEmpty) ...[
                    ClientsLogoStripWidget(clients: clients),
                    const SizedBox(height: 20),
                  ],

                  // 5. Dynamic Awards & Accreditations (Sitefinity /images ParentId awards)
                  if (awards.isNotEmpty) ...[
                    AwardsCarouselWidget(awards: awards),
                    const SizedBox(height: 24),
                  ],

                  // 6. Featured Insights & Content (Sitefinity /api/idealake/contents)
                  if (contents.isNotEmpty) ...[
                    FeaturedContentWidget(contents: contents),
                    const SizedBox(height: 24),
                  ],

                  // 7. Dynamic Services Section (Sitefinity /contents)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Solutions & Capabilities',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enterprise architecture engineered by Idealake for LTFS',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Filter Chips
                  _buildCategoryFilter(state.selectedCategory),
                  const SizedBox(height: 16),

                  // Services 2-Column Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredServices.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return ServiceCardWidget(
                          service: service,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(String selectedCategory) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = selectedCategory == category;
          return ChoiceChip(
            label: Text(
              category,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            showCheckmark: false,
            onSelected: (_) {
              context.read<HomeBloc>().add(HomeCategorySelectedEvent(category));
            },
          );
        },
      ),
    );
  }
}
