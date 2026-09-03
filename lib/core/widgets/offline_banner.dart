import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

/// Top banner showing offline / cached content indicator
class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRefresh;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.secondary,
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textWhite, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode: Serving last-known cached content',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onRefresh != null)
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                'Retry',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textWhite,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
