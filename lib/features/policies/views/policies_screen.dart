import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_chip_filter.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../view_model/policies_bloc.dart';
import '../view_model/policies_event.dart';
import '../view_model/policies_state.dart';
import '../widgets/policy_card.dart';
import 'policy_viewer_screen.dart';

/// Screen displaying the list of organizational policies with versioning
class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'IT & Security', 'Compliance', 'Human Resources'];

  @override
  void initState() {
    super.initState();
    context.read<PoliciesBloc>().add(const PoliciesFetchEvent());
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
      body: BlocBuilder<PoliciesBloc, PoliciesState>(
        builder: (context, state) {
          return Column(
            children: [
              OfflineBanner(
                isOffline: state.isOffline,
                onRefresh: () {
                  context.read<PoliciesBloc>().add(const PoliciesFetchEvent(forceRefresh: true));
                },
              ),
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search policies, versions, compliance...',
                onChanged: (q) {
                  context.read<PoliciesBloc>().add(PoliciesSearchEvent(q));
                },
              ),
              CustomChipFilter(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: (cat) {
                  context.read<PoliciesBloc>().add(PoliciesCategoryFilterEvent(cat));
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<PoliciesBloc>().add(const PoliciesFetchEvent(forceRefresh: true));
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

  Widget _buildContent(PoliciesState state) {
    if (state.response.isLoading && (state.response.data == null || state.response.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading Sitefinity Policies...');
    }

    if (state.response.isError && (state.response.data == null || state.response.data!.isEmpty)) {
      return ErrorView(
        message: state.response.message,
        onRetry: () {
          context.read<PoliciesBloc>().add(const PoliciesFetchEvent(forceRefresh: true));
        },
      );
    }

    final policies = state.response.data ?? [];

    if (policies.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 60),
          EmptyStateView(
            title: 'No Policies Found',
            message: 'No organizational policies match your filter selection.',
            icon: Icons.policy_outlined,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: policies.length,
      itemBuilder: (context, index) {
        final item = policies[index];
        return PolicyCard(
          policy: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PolicyViewerScreen(policy: item),
              ),
            );
          },
        );
      },
    );
  }
}
