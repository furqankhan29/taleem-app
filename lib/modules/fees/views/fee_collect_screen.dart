import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/modules/fees/controllers/fee_collect_controller.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/loading_overlay.dart';

class FeeCollectScreen extends GetView<FeeCollectController> {
  const FeeCollectScreen({super.key});

  void _showImagePickerSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Payment Slip',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickReceiptSlip(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickReceiptSlip(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect Payment'),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isSaving.value || controller.isUploading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Invoice Summary details
                    if (controller.selectedFee.value != null)
                      _buildInvoiceSummary(),
                    const SizedBox(height: 20.0),

                    // Amount to pay Input Field
                    TextFormField(
                      initialValue: controller.payAmount.value.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
                        prefixText: '\$ ',
                        hintText: 'Enter amount...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        final amt = double.tryParse(value);
                        if (amt == null || amt <= 0) return 'Must be greater than 0';
                        if (amt > (controller.selectedFee.value?.balanceDue ?? 0.0)) {
                          return 'Cannot exceed balance due';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        final amt = double.tryParse(val);
                        if (amt != null) controller.payAmount.value = amt;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Mode Selection Dropdown
                    DropdownButtonFormField<String>(
                      value: controller.paymentMethod.value,
                      items: controller.paymentMethods.map((method) {
                        return DropdownMenuItem(value: method, child: Text(method));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.paymentMethod.value = val;
                      },
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                    ),
                    const SizedBox(height: 16.0),

                    // Optional Transaction ID Input
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Transaction ID (Optional)',
                        hintText: 'e.g. Bank Ref No / Easypaisa TXN ID',
                      ),
                      onChanged: (val) => controller.transactionId.value = val.trim(),
                    ),
                    const SizedBox(height: 16.0),

                    // Slip Upload File Picker Widget
                    _buildSlipPicker(context),
                    const SizedBox(height: 24.0),

                    // Note Text area
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Internal Note (Optional)',
                        hintText: 'Enter any payment notes or remarks...',
                      ),
                      onChanged: (val) => controller.note.value = val.trim(),
                    ),
                    const SizedBox(height: 32.0),

                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.collectPayment();
                        }
                      },
                      child: const Text('Record Transaction'),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildInvoiceSummary() {
    final fee = controller.selectedFee.value!;
    final student = controller.selectedStudent.value;

    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE DETAIL',
            style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 8.0),
          _buildRowInfo('Student', student?.name ?? 'Loading Student...'),
          _buildRowInfo('Invoice ID', fee.id),
          _buildRowInfo('Type', fee.type.name.toUpperCase()),
          _buildRowInfo('Term', fee.term ?? 'Monthly'),
          _buildRowInfo('Total Amount', Formatters.toCurrency(fee.amount)),
          _buildRowInfo('Remaining Balance', Formatters.toCurrency(fee.balanceDue), isBoldValue: true, valueColor: AppColors.tertiary),
        ],
      ),
    );
  }

  Widget _buildRowInfo(
    String label,
    String value, {
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipPicker(BuildContext context) {
    final file = controller.selectedReceiptSlip.value;
    
    return GestureDetector(
      onTap: () => _showImagePickerSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.regular),
          border: Border.all(color: AppColors.outlineVariant, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
              color: file != null ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                file != null ? 'Receipt slip attached: ${file.path.split('/').last}' : 'Attach Payment Slip / Screenshot',
                style: AppTypography.bodySmall.copyWith(color: file != null ? AppColors.onSurface : AppColors.outline),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (file != null)
              IconButton(
                icon: const Icon(Icons.cancel_outlined, size: 18.0),
                onPressed: () => controller.selectedReceiptSlip.value = null,
              ),
          ],
        ),
      ),
    );
  }
}
