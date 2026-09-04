import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/news_model.dart';
import '../view_model/news_bloc.dart';
import '../view_model/news_event.dart';

/// Screen for creating and editing news articles with responsive layouts and non-overlapping safe areas
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
  bool _moreOptionsExpanded = false;

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
      UIHelpers.showSnackBar(context, 'Please enter a title for the news article', isError: true);
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
      isPublished ? 'News article "$title" published successfully!' : 'Draft saved successfully!',
    );

    Navigator.pop(context);
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00965E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final cat = catController.text.trim();
              if (cat.isNotEmpty && !_selectedCategories.contains(cat)) {
                setState(() => _selectedCategories.add(cat));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
        title: const Text('Add Tag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00965E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final tag = tagController.text.trim().replaceAll('#', '');
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          isEditing ? 'Edit News Article' : 'Create News Article',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _saveNews(isPublished: false),
            icon: const Icon(Icons.save_outlined, size: 18, color: AppColors.primary),
            label: Text(
              'Save Draft',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title Input
                CustomTextField(
                  label: 'Title',
                  hintText: 'e.g. Idealake Announces Digital Platform Expansion',
                  controller: _titleController,
                  prefixIcon: const Icon(Icons.title_rounded, size: 20, color: AppColors.textSecondary),
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Title'),
                ),
                const SizedBox(height: 18),

                // 2. Content Input
                CustomTextField(
                  label: 'Content',
                  hintText: 'Write the full news article content here...',
                  controller: _contentController,
                  minLines: 6,
                  maxLines: 12,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 18),

                // 3. Summary Section
                CustomTextField(
                  label: 'Summary',
                  hintText: 'Provide a brief summary or abstract of this article...',
                  controller: _summaryController,
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1),

                // 4. Categories and Tags Accordion
                _buildAccordionSection(
                  title: 'Categories & Tags',
                  icon: Icons.label_outline_rounded,
                  isExpanded: _categoriesExpanded,
                  onToggle: () => setState(() => _categoriesExpanded = !_categoriesExpanded),
                  children: [
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                side: const BorderSide(color: Color(0xFF00965E), width: 0.8),
                              ),
                              labelStyle: const TextStyle(color: Color(0xFF00965E), fontWeight: FontWeight.bold),
                              deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF00965E)),
                              onDeleted: () {
                                setState(() => _selectedCategories.remove(cat));
                              },
                            )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16, color: Color(0xFF003D99)),
                          label: const Text('Add Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: _showAddCategoryDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                side: const BorderSide(color: AppColors.border, width: 0.8),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                setState(() => _tags.remove(tag));
                              },
                            )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16, color: Color(0xFF003D99)),
                          label: const Text('Add Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: _showAddTagDialog,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1),

                // 5. Additional info (Author, Source) Accordion
                _buildAccordionSection(
                  title: 'Additional Info (Author, Source)',
                  icon: Icons.person_outline_rounded,
                  isExpanded: _additionalInfoExpanded,
                  onToggle: () => setState(() => _additionalInfoExpanded = !_additionalInfoExpanded),
                  children: [
                    CustomTextField(
                      label: 'Author',
                      hintText: 'e.g. Pooja Shelke',
                      controller: _authorController,
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Source Name',
                      hintText: 'e.g. Idealake Press',
                      controller: _sourceNameController,
                      prefixIcon: const Icon(Icons.business_outlined, size: 18),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Source URL',
                      hintText: 'https://...',
                      controller: _sourceUrlController,
                      prefixIcon: const Icon(Icons.link_rounded, size: 18),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1),

                // 6. More options (URL, Comments) Accordion
                _buildAccordionSection(
                  title: 'More Options (URL, SEO)',
                  icon: Icons.tune_rounded,
                  isExpanded: _moreOptionsExpanded,
                  onToggle: () => setState(() => _moreOptionsExpanded = !_moreOptionsExpanded),
                  children: [
                    CustomTextField(
                      label: 'URL Slug',
                      hintText: 'e.g. new-platform-announcement',
                      controller: _urlController,
                      prefixIcon: const Icon(Icons.language_rounded, size: 18),
                    ),
                    const SizedBox(height: 14),

                    // Include in sitemap checkbox
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF00965E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      title: Text(
                        'Include in sitemap',
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Allow search engines to index this content in Sitemap',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _includeInSitemap,
                      onChanged: (val) => setState(() => _includeInSitemap = val ?? true),
                    ),

                    // Comments checkbox
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF00965E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      title: Text(
                        'Allow Comments',
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Allow readers to post comments on this article',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _allowComments,
                      onChanged: (val) => setState(() => _allowComments = val ?? true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _saveNews(isPublished: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                      ),
                      child: const Text(
                        'Save as Draft',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveNews(isPublished: true),
                      icon: const Icon(Icons.publish_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Publish Article',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00965E), // Sitefinity green
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required IconData icon,
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, size: 18, color: const Color(0xFF003D99)),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
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
            padding: const EdgeInsets.only(left: 6.0, bottom: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }
}
