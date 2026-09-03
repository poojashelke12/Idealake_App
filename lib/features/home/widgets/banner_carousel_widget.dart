import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/idealake_image_model.dart';

/// Banner Widget displaying the hero image for Home screen
class BannerCarouselWidget extends StatefulWidget {
  final List<IdealakeImageModel> banners;

  const BannerCarouselWidget({super.key, required this.banners});

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strictly filter to only display banner_1920
    final displayBanners = widget.banners.where((b) => b.isBanner1920).toList();

    if (displayBanners.isEmpty) return const SizedBox.shrink();

    // Single banner display
    if (displayBanners.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: _buildBannerImage(displayBanners.first),
      );
    }

    // Multiple banners carousel
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1920 / 726,
          child: PageView.builder(
            controller: _pageController,
            itemCount: displayBanners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: _buildBannerImage(displayBanners[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            displayBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerImage(IdealakeImageModel banner) {
    final imageUrl = banner.url.isNotEmpty ? banner.url : (banner.thumbnailUrl ?? '');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AspectRatio(
          aspectRatio: banner.calculatedAspectRatio,
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.shimmerBase,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.primaryContainer,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.primaryContainer,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
