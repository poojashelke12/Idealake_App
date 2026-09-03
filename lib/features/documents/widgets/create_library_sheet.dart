import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Modal sheet to create a new Document Library matching Sitefinity Web Admin UI (Screenshot 4)
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
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      UIHelpers.showSnackBar(context, 'Please type a library name', isError: true);
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
              // Close (✕) icon on the top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Large Title Input: "Type library name" (Screenshot 4)
              TextField(
                controller: _titleController,
                autofocus: true,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type library name',
                  hintStyle: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
              ),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1),
              const SizedBox(height: 20),

              // Hierarchy radio options: "Put this library..." (Screenshot 4)
              Text(
                'Put this library...',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: () => setState(() => _hierarchyLevel = 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hierarchyLevel == 0 ? const Color(0xFF00965E) : AppColors.border,
                            width: _hierarchyLevel == 0 ? 5 : 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('On top level', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _hierarchyLevel = 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _hierarchyLevel == 1 ? const Color(0xFF00965E) : AppColors.border,
                            width: _hierarchyLevel == 1 ? 5 : 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Under parent library...', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Storage Provider (Screenshot 4)
              Row(
                children: [
                  Text(
                    'Storage provider',
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
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStorage,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Database (default)', child: Text('Database (default)')),
                      DropdownMenuItem(value: 'Azure Blob', child: Text('Azure Blob Storage')),
                      DropdownMenuItem(value: 'File System', child: Text('Local File System')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStorage = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Green Create button matching Screenshot 4 (#00965E)
              SizedBox(
                height: 44,
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00965E), // Sitefinity green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  onPressed: _handleSubmit,
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
