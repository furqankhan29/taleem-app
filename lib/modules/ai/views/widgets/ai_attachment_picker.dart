import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';

class AIAttachmentPicker extends StatelessWidget {
  final VoidCallback? onImagePick;
  final VoidCallback? onDocumentPick;
  final VoidCallback? onVoiceRecord;
  final bool isEnabled;

  const AIAttachmentPicker({
    super.key,
    this.onImagePick,
    this.onDocumentPick,
    this.onVoiceRecord,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      enabled: isEnabled,
      offset: const Offset(0, -160),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceContainerHighDark
          : AppColors.surfaceContainerLowest,
      onSelected: (value) {
        switch (value) {
          case 0:
            onImagePick?.call();
            break;
          case 1:
            onDocumentPick?.call();
            break;
          case 2:
            onVoiceRecord?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.mic_rounded, color: AppColors.primary),
            title: Text('Voice Input'),
            subtitle: Text('Record or upload audio'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.image_rounded, color: AppColors.secondary),
            title: Text('Image / OCR'),
            subtitle: Text('Extract text from image'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.description_rounded, color: AppColors.tertiary),
            title: Text('Document / PDF'),
            subtitle: Text('Analyze documents'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: const Icon(
          Icons.attach_file_rounded,
          color: AppColors.onSurfaceVariant,
          size: 22.0,
        ),
      ),
    );
  }
}
