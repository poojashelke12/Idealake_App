import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/news_model.dart';
import '../view_model/news_bloc.dart';
import '../view_model/news_event.dart';

/// Screen for creating and publishing news articles matching Sitefinity Web Admin UI
class CreateNewsScreen extends StatefulWidget {
  final NewsModel? initialNews;

  const CreateNewsScreen({super.key, this.initialNews});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _summaryController;
  late final TextEditingController _authorController;
  late final TextEditingController _sourceNameController;
  late final TextEditingController _sourceUrlController;
  late final TextEditingController _urlController;

  late List<String> _selectedCategories;
  late List<String> _tags;
  late bool _includeInSitemap;
  late bool _allowComments;

  bool _categoriesExpanded = true;
  bool _additionalInfoExpanded = true;
  bool _moreOptionsExpanded = true;

  @override
  void initState() {
    super.initState();
    final init = widget.initialNews;
    _titleController = TextEditingController(text: init?.title ?? '');
    _contentController = TextEditingController(text: init?.contentHtml ?? '');
    _summaryController = TextEditingController(text: init?.summary ?? '');
    _authorController = TextEditingController(text: init?.author ?? 'Pooja Shelke');
    _sourceNameController = TextEditingController(text: init?.sourceName ?? '');
    _sourceUrlController = TextEditingController(text: init?.sourceUrl ?? '');
    _urlController = TextEditingController(text: init?.urlName ?? '');

    _selectedCategories = init != null ? [init.category] : ['Technology'];
    _tags = init != null ? List.from(init.tags) : ['Sitefinity', 'CMS'];
    _includeInSitemap = init?.includeInSitemap ?? true;
    _allowComments = init?.allowComments ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _authorController.dispose();
    _sourceNameController.dispose();
    _sourceUrlController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveNews({required bool isPublished}) {
    if (_titleController.text.trim().isEmpty) {
      UIHelpers.showSnackBar(context, 'Please enter a title for the news item', isError: true);
      return;
    }

    final now = DateTime.now();
    final title = _titleController.text.trim();
    final urlSlug = _urlController.text.trim().isNotEmpty
        ? _urlController.text.trim()
        : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    final newsItem = NewsModel(
      id: widget.initialNews?.id ?? 'news-${now.millisecondsSinceEpoch}',
      title: title,
      summary: _summaryController.text.trim().isNotEmpty
          ? _summaryController.text.trim()
          : title,
      contentHtml: _contentController.text.trim().isNotEmpty
          ? _contentController.text.trim()
          : '<p>$title</p>',
      publishedDate: widget.initialNews?.publishedDate ?? now,
      lastModified: now,
      dateCreated: widget.initialNews?.dateCreated ?? now,
      author: _authorController.text.trim().isNotEmpty ? _authorController.text.trim() : 'Pooja Shelke',
      sourceName: _sourceNameController.text.trim().isNotEmpty ? _sourceNameController.text.trim() : null,
      sourceUrl: _sourceUrlController.text.trim().isNotEmpty ? _sourceUrlController.text.trim() : null,
      urlName: urlSlug,
      itemDefaultUrl: '/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/$urlSlug',
      allowComments: _allowComments,
      includeInSitemap: _includeInSitemap,
      status: isPublished ? 'Published' : 'Draft',
      category: _selectedCategories.isNotEmpty ? _selectedCategories.first : 'General',
      tags: _tags,
    );

    context.read<NewsBloc>().add(NewsCreateEvent(newsItem));

    UIHelpers.showSuccessSnackBar(
      context,
      isPublished ? 'News item "$title" published successfully!' : 'Draft saved successfully!',
    );

    Navigator.pop(context);
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Technology, Corporate, Innovation',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
            onPressed: () {
              final cat = catController.text.trim();
              if (cat.isNotEmpty && !_selectedCategories.contains(cat)) {
                setState(() => _selectedCategories.add(cat));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: tagController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Sitefinity, Mobile, Cloud',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
            onPressed: () {
              final tag = tagController.text.trim().replaceAll('#', '');
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNews != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          isEditing ? 'Editing news item...' : 'Creating a news item...',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Publish Button (Green CTA matching screenshot)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () => _saveNews(isPublished: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00965E), // Sitefinity green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
              ),
              child: const Text(
                'Publish',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),

          // Save as Draft
          TextButton(
            onPressed: () => _saveNews(isPublished: false),
            child: Text(
              'Save as Draft',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Input (Large matching screenshot)
              TextField(
                controller: _titleController,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),
              const SizedBox(height: 12),

              // 2. Content Input
              TextField(
                controller: _contentController,
                minLines: 6,
                maxLines: 15,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Content',
                  hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),
              const SizedBox(height: 16),

              // 3. Summary Section (matching screenshot)
              Text(
                'Summary',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: TextField(
                  controller: _summaryController,
                  minLines: 3,
                  maxLines: 5,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Provide a brief summary of this article...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),

              // 4. Categories and tags Accordion (Screenshot 2 & 3)
              _buildAccordionSection(
                title: 'Categories and tags',
                isExpanded: _categoriesExpanded,
                onToggle: () => setState(() => _categoriesExpanded = !_categoriesExpanded),
                children: [
                  // Categories
                  Text(
                    'Categories',
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedCategories.map((cat) => Chip(
                            label: Text(cat, style: const TextStyle(fontSize: 12)),
                            backgroundColor: const Color(0xFFE6F4EA),
                            labelStyle: const TextStyle(color: Color(0xFF00965E), fontWeight: FontWeight.bold),
                            deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF00965E)),
                            onDeleted: () {
                              setState(() => _selectedCategories.remove(cat));
                            },
                          )),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        label: const Text('Add Category', style: TextStyle(fontSize: 12)),
                        onPressed: _showAddCategoryDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Text(
                    'Tags',
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                            label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.background,
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              setState(() => _tags.remove(tag));
                            },
                          )),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        label: const Text('Add Tag', style: TextStyle(fontSize: 12)),
                        onPressed: _showAddTagDialog,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),

              // 5. Additional info (Author, Source) Accordion (Screenshot 3 & 4)
              _buildAccordionSection(
                title: 'Additional info (Author, Source)',
                isExpanded: _additionalInfoExpanded,
                onToggle: () => setState(() => _additionalInfoExpanded = !_additionalInfoExpanded),
                children: [
                  CustomTextField(
                    label: 'Author',
                    hintText: 'e.g. Pooja Shelke',
                    controller: _authorController,
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Source name',
                    hintText: 'e.g. Idealake Press',
                    controller: _sourceNameController,
                    prefixIcon: const Icon(Icons.business_outlined, size: 18),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Source URL',
                    hintText: 'https://...',
                    controller: _sourceUrlController,
                    prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),

              // 6. More options (URL, Comments) Accordion (Screenshot 4 & 5)
              _buildAccordionSection(
                title: 'More options (URL, Comments)',
                isExpanded: _moreOptionsExpanded,
                onToggle: () => setState(() => _moreOptionsExpanded = !_moreOptionsExpanded),
                children: [
                  CustomTextField(
                    label: 'URL',
                    hintText: 'Enter URL slug (e.g. new-platform-announcement)',
                    controller: _urlController,
                    prefixIcon: const Icon(Icons.language_rounded, size: 18),
                  ),
                  const SizedBox(height: 14),

                  // Include in sitemap checkbox matching screenshot
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF00965E),
                    title: Text(
                      'Include in sitemap',
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Allow external search engines to index this content and include in Sitemap',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    value: _includeInSitemap,
                    onChanged: (val) => setState(() => _includeInSitemap = val ?? true),
                  ),

                  // Comments checkbox matching screenshot
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF00965E),
                    title: Text(
                      'Comments',
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Allow comments',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    value: _allowComments,
                    onChanged: (val) => setState(() => _allowComments = val ?? true),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bottom Action Buttons (Screenshot 5)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveNews(isPublished: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00965E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Publish',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _saveNews(isPublished: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                      ),
                      child: const Text(
                        'Save as Draft',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }
}
