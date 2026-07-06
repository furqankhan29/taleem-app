import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class FeeReceiptScreen extends StatelessWidget {
  const FeeReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: const Center(child: Text('No receipt arguments provided.')),
      );
    }

    final fee = args['fee'] as FeeModel;
    final payment = args['payment'] as FeePayment;
    final student = args['student'] as StudentModel?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Get.offAllNamed(AppRoutes.feeManagement),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Indicator Header
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64.0,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Payment Received!',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Glass Slip Receipt Card
              GlassCard(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'TALEEM TUITION SYSTEM',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Official Payment Acknowledgement',
                      style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.outline),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 12.0),

                    _buildInfoRow('Student Name', student?.name ?? 'Loading...'),
                    _buildInfoRow('Student ID', student?.studentId ?? 'N/A'),
                    _buildInfoRow('Invoice ID', fee.id),
                    _buildInfoRow('Payment Date', Formatters.formatDate(payment.date)),
                    _buildInfoRow('Category / Type', fee.type.name.capitalizeFirst!),
                    _buildInfoRow('Payment Mode', payment.method ?? 'Cash'),
                    if (payment.transactionId != null)
                      _buildInfoRow('Transaction Ref', payment.transactionId!),
                    const SizedBox(height: 12.0),
                    const Divider(),
                    const SizedBox(height: 12.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AMOUNT PAID',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          Formatters.toCurrency(payment.amount),
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining Balance Due',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                        ),
                        Text(
                          Formatters.toCurrency(fee.balanceDue),
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              // Action buttons (Print/Share/PDF)
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate Print / PDF receipt generator
                  Get.rawSnackbar(
                    title: 'Generating PDF Invoice',
                    message: 'Receipt PDF document saved to downloads directory',
                    duration: const Duration(seconds: 3),
                  );
                },
                icon: const Icon(Icons.print_rounded),
                label: const Text('Download Receipt PDF'),
              ),
              const SizedBox(height: 12.0),
              OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.feeManagement),
                child: const Text('Back to Dues Ledger'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
