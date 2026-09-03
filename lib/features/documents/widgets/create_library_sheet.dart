import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Modal sheet to create a new Document Library (matches Sitefinity Web Action)
class CreateLibrarySheet extends StatefulWidget {
  const CreateLibrarySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateLibrarySheet(),
    );
  }

  @override
  State<CreateLibrarySheet> createState() => _CreateLibrarySheetState();
}

class _CreateLibrarySheetState extends State<CreateLibrarySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStorage = 'Database';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DocumentsBloc>().add(
            DocumentsCreateLibraryEvent(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              storedIn: _selectedStorage,
            ),
          );
      Navigator.pop(context);
      UIHelpers.showSuccessSnackBar(context, 'Created library "${_titleController.text.trim()}" in Sitefinity CMS!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.create_new_folder_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create a Library',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Library Name *',
                hintText: 'e.g. ResumeDocument, KYC Records',
                controller: _titleController,
                validator: (v) => Validators.validateRequired(v, fieldName: 'Library name'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description',
                hintText: 'Optional description of library contents',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              Text(
                'Storage Provider',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedStorage,
                items: const [
                  DropdownMenuItem(value: 'Database', child: Text('Database (Default)')),
                  DropdownMenuItem(value: 'Azure Blob', child: Text('Azure Blob Storage')),
                  DropdownMenuItem(value: 'File System', child: Text('Local File System')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStorage = val);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Library',
                prefixIcon: const Icon(Icons.check_rounded, color: AppColors.textWhite, size: 18),
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
