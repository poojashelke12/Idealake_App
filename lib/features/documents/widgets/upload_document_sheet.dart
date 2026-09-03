import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/document_library_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Modal sheet to upload a document into a Library (matches Sitefinity Web Action)
class UploadDocumentSheet extends StatefulWidget {
  final List<DocumentLibraryModel> libraries;
  final DocumentLibraryModel? defaultLibrary;

  const UploadDocumentSheet({
    super.key,
    required this.libraries,
    this.defaultLibrary,
  });

  static void show(BuildContext context, List<DocumentLibraryModel> libraries, {DocumentLibraryModel? defaultLibrary}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadDocumentSheet(libraries: libraries, defaultLibrary: defaultLibrary),
    );
  }

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedLibraryId;
  String _fileExtension = 'pdf';
  String _category = 'General';

  @override
  void initState() {
    super.initState();
    if (widget.defaultLibrary != null) {
      _selectedLibraryId = widget.defaultLibrary!.id;
    } else if (widget.libraries.isNotEmpty) {
      _selectedLibraryId = widget.libraries.first.id;
    } else {
      _selectedLibraryId = 'lib-001';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedLib = widget.libraries.firstWhere(
        (lib) => lib.id == _selectedLibraryId,
        orElse: () => const DocumentLibraryModel(id: 'lib-001', title: 'ResumeDocument'),
      );

      context.read<DocumentsBloc>().add(
            DocumentsUploadFileEvent(
              title: _titleController.text.trim(),
              libraryId: selectedLib.id,
              libraryTitle: selectedLib.title,
              description: _descriptionController.text.trim(),
              fileExtension: _fileExtension,
              fileSize: '2.3 MB',
              category: _category,
            ),
          );
      Navigator.pop(context);
      UIHelpers.showSuccessSnackBar(context, 'Uploaded "${_titleController.text.trim()}" to ${selectedLib.title}!');
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
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: AppColors.success, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Upload Documents',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (widget.libraries.isNotEmpty) ...[
                Text(
                  'Target Document Library',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLibraryId,
                  items: widget.libraries.map((lib) {
                    return DropdownMenuItem(
                      value: lib.id,
                      child: Text('${lib.title} (${lib.documentCount} items)'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLibraryId = val);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              CustomTextField(
                label: 'Document Title *',
                hintText: 'e.g. Q4_Executive_Summary.pdf',
                controller: _titleController,
                validator: (v) => Validators.validateRequired(v, fieldName: 'Document title'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('File Type', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _fileExtension,
                          items: const [
                            DropdownMenuItem(value: 'pdf', child: Text('PDF (.pdf)')),
                            DropdownMenuItem(value: 'docx', child: Text('Word (.docx)')),
                            DropdownMenuItem(value: 'xlsx', child: Text('Excel (.xlsx)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _fileExtension = val);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          items: const [
                            DropdownMenuItem(value: 'General', child: Text('General')),
                            DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                            DropdownMenuItem(value: 'Financial', child: Text('Financial')),
                            DropdownMenuItem(value: 'Compliance', child: Text('Compliance')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Upload to Sitefinity CMS',
                backgroundColor: AppColors.success,
                prefixIcon: const Icon(Icons.cloud_upload_rounded, color: AppColors.textWhite, size: 18),
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
