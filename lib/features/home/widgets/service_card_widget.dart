import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/service_item_model.dart';

/// Service item card widget displayed on the Home grid/list
class ServiceCardWidget extends StatelessWidget {
  final ServiceItemModel service;
  final VoidCallback? onTap;

  const ServiceCardWidget({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      borderRadius: AppConstants.radiusMedium,
      elevation: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  _resolveIcon(service.iconName),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              if (service.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    service.category!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            service.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              service.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Explore Service',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String? iconName) {
    switch (iconName) {
      case 'devices_rounded':
        return Icons.devices_rounded;
      case 'web_rounded':
        return Icons.web_rounded;
      case 'account_balance_wallet_rounded':
        return Icons.account_balance_wallet_rounded;
      case 'cloud_done_rounded':
        return Icons.cloud_done_rounded;
      case 'brush_rounded':
        return Icons.brush_rounded;
      case 'api_rounded':
        return Icons.api_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
