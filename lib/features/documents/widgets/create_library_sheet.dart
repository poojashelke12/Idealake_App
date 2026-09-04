import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Modal sheet to create a new Document Library matching Sitefinity Web Admin & App Theme
class CreateLibrarySheet extends StatefulWidget {
  const CreateLibrarySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<DocumentsBloc>(),
        child: const CreateLibrarySheet(),
      ),
    );
  }

  @override
  State<CreateLibrarySheet> createState() => _CreateLibrarySheetState();
}

class _CreateLibrarySheetState extends State<CreateLibrarySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedStorage = 'Database (default)';
  int _hierarchyLevel = 0; // 0 = On top level, 1 = Under parent library

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final storageClean = _selectedStorage.replaceAll(' (default)', '');

      context.read<DocumentsBloc>().add(
            DocumentsCreateLibraryEvent(
              title: title,
              storedIn: storageClean,
            ),
          );
      Navigator.pop(context);
      UIHelpers.showSuccessSnackBar(context, 'Created library "$title" in Sitefinity CMS!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row: Title and Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.create_new_folder_outlined,
                          color: Color(0xFF00965E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Create a Library',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Standard Clean Library Name Input
              CustomTextField(
                label: 'Library Name',
                hintText: 'e.g. Press Releases, Marketing Assets',
                controller: _titleController,
                prefixIcon: const Icon(Icons.folder_outlined, size: 20, color: AppColors.textSecondary),
                validator: (v) => Validators.validateRequired(v, fieldName: 'Library Name'),
              ),
              const SizedBox(height: 16),

              // Hierarchy radio options
              Text(
                'Hierarchy Placement',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _hierarchyLevel = 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hierarchyLevel == 0 ? const Color(0xFF00965E) : AppColors.border,
                            width: _hierarchyLevel == 0 ? 5 : 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'On top level',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: _hierarchyLevel == 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _hierarchyLevel = 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hierarchyLevel == 1 ? const Color(0xFF00965E) : AppColors.border,
                            width: _hierarchyLevel == 1 ? 5 : 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Under parent library...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: _hierarchyLevel == 1 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Storage Provider Dropdown
              Row(
                children: [
                  Text(
                    'Storage Provider',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStorage,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    items: const [
                      DropdownMenuItem(
                        value: 'Database (default)',
                        child: Row(
                          children: [
                            Icon(Icons.storage_rounded, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 10),
                            Text('Database (default)', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Azure Blob',
                        child: Row(
                          children: [
                            Icon(Icons.cloud_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 10),
                            Text('Azure Blob Storage', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'File System',
                        child: Row(
                          children: [
                            Icon(Icons.folder_shared_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 10),
                            Text('Local File System', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStorage = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00965E), // Sitefinity green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _handleSubmit,
                        child: const Text(
                          'Create Library',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
