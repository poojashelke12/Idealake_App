import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_chip_filter.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../view_model/announcements_bloc.dart';
import '../view_model/announcements_event.dart';
import '../view_model/announcements_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/announcement_detail_sheet.dart';

/// Screen displaying the Announcements Feed (Home Tab)
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _audiences = ['All', 'All Employees', 'IT & Engineering', 'Operations', 'Leadership'];

  @override
  void initState() {
    super.initState();
    context.read<AnnouncementsBloc>().add(const AnnouncementsFetchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          return Column(
            children: [
              // Offline mode indicator
              OfflineBanner(
                isOffline: state.isOffline,
                onRefresh: () {
                  context.read<AnnouncementsBloc>().add(const AnnouncementsFetchEvent(forceRefresh: true));
                },
              ),

              // Search Bar
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search announcements...',
                onChanged: (q) {
                  context.read<AnnouncementsBloc>().add(AnnouncementsSearchEvent(q));
                },
              ),

              // Audience Filter Chips
              CustomChipFilter(
                categories: _audiences,
                selectedCategory: state.selectedAudience,
                onSelected: (cat) {
                  context.read<AnnouncementsBloc>().add(AnnouncementsAudienceFilterEvent(cat));
                },
              ),
              const SizedBox(height: 8),

              // Announcements List / States
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<AnnouncementsBloc>().add(const AnnouncementsFetchEvent(forceRefresh: true));
                  },
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AnnouncementsState state) {
    if (state.response.isLoading && (state.response.data == null || state.response.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading Sitefinity Announcements...');
    }

    if (state.response.isError && (state.response.data == null || state.response.data!.isEmpty)) {
      return ErrorView(
        message: state.response.message,
        onRetry: () {
          context.read<AnnouncementsBloc>().add(const AnnouncementsFetchEvent(forceRefresh: true));
        },
      );
    }

    final announcements = state.response.data ?? [];

    if (announcements.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 60),
          EmptyStateView(
            title: 'No Announcements Found',
            message: 'No active announcements match your filter criteria.',
            icon: Icons.campaign_outlined,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final item = announcements[index];
        return AnnouncementCard(
          announcement: item,
          onTap: () {
            context.read<AnnouncementsBloc>().add(AnnouncementsMarkAsReadEvent(item.id));
            AnnouncementDetailSheet.show(context, item);
          },
        );
      },
    );
  }
}
