import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../models/news_model.dart';
import 'create_news_screen.dart';

/// Screen displaying the full Rich-Text News Article & Hero Media
class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final isPublished = news.status.toLowerCase() == 'published';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'News Article',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            tooltip: 'Edit Article',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNewsScreen(initialNews: news),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            tooltip: 'Share Article',
            onPressed: () {
              UIHelpers.showSuccessSnackBar(context, 'Link to "${news.title}" copied to clipboard');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image if present
            if (news.heroImageUrl != null && news.heroImageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: news.heroImageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 220,
                  color: AppColors.primaryContainer,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  color: AppColors.primaryContainer,
                  child: const Icon(Icons.newspaper_rounded, size: 48, color: AppColors.primary),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Category Row
                  Row(
                    children: [
                      // Published Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPublished ? const Color(0xFFE6F4EA) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPublished ? const Color(0xFF00965E).withValues(alpha: 0.3) : const Color(0xFFD97706),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPublished ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                              size: 14,
                              color: isPublished ? const Color(0xFF00965E) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news.status,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isPublished ? const Color(0xFF00965E) : const Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.category,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Formatted date
                      Text(
                        news.formattedAuthorAndDate,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    news.title,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Summary Callout Box
                  if (news.summary.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF00965E), width: 4),
                        ),
                      ),
                      child: Text(
                        news.summary,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Body Content Formatted
                  _buildArticleContent(news.contentHtml),
                  const SizedBox(height: 24),

                  // Source Info (if available)
                  if (news.sourceName != null && news.sourceName!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.source_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Source: ${news.sourceName}',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags Section
                  if (news.tags.isNotEmpty) ...[
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    Text(
                      'Tags & Topics',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: news.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            '#$tag',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF00965E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Comments section indicator
                  if (news.allowComments) ...[
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            UIHelpers.showSnackBar(context, 'Comments feature enabled for this article.');
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF00965E)),
                          label: const Text(
                            'Add Comment',
                            style: TextStyle(color: Color(0xFF00965E), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(String htmlContent) {
    if (htmlContent.isEmpty) return const SizedBox.shrink();

    final plainText = htmlContent
        .replaceAll(RegExp(r'<h3[^>]*>'), '\n\n### ')
        .replaceAll(RegExp(r'</h3>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<li[^>]*>'), '\n• ')
        .replaceAll(RegExp(r'</li>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return Text(
      plainText.isNotEmpty ? plainText : 'No content body available.',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimary,
        height: 1.7,
      ),
    );
  }
}
