import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/batch_model.dart';
import 'package:taleem/modules/batches/controllers/batch_controller.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class BatchListScreen extends StatefulWidget {
  const BatchListScreen({super.key});

  @override
  State<BatchListScreen> createState() => _BatchListScreenState();
}

class _BatchListScreenState extends State<BatchListScreen> {
  final BatchController controller = Get.find<BatchController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () { controller.clearFilters(); Get.back(); },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Schedule', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BatchSchedule>(
              value: controller.selectedSchedule.value,
              items: BatchSchedule.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
              onChanged: (val) => controller.selectedSchedule.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 16),
            Text('Status', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BatchStatus>(
              value: controller.selectedStatus.value,
              items: BatchStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst ?? s.name))).toList(),
              onChanged: (val) => controller.selectedStatus.value = val,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () { controller.loadItems(refresh: true); Get.back(); },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.active: return Colors.green;
      case BatchStatus.inactive: return Colors.red;
      case BatchStatus.completed: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (_) => _buildContent(context),
        desktop: (_) => _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return _buildShimmerList();
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Search batches...',
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.batchForm),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.add_rounded, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.items.isEmpty
                ? const EmptyState(
                    icon: Icons.book_rounded,
                    title: 'No Batches Found',
                    subtitle: 'Create a batch to get started.',
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.loadItems(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.items.length + (controller.isMoreLoading.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final batch = controller.items[index];
                        return _buildBatchCard(batch);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildBatchCard(BatchModel batch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Get.toNamed(AppRoutes.batchForm, arguments: batch),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batch.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusChip(
                  label: batch.status.name,
                  color: _statusColor(batch.status),
                  textColor: _statusColor(batch.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              batch.code,
              style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  batch.schedule.name.capitalizeFirst ?? batch.schedule.name,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const Spacer(),
                Icon(Icons.people_rounded, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${batch.currentStrength}/${batch.maxCapacity}',
                  style: AppTypography.bodySmall.copyWith(
                    color: batch.isFull ? AppColors.error : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (batch.days.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: batch.days.map((d) => Chip(
                  label: Text(d, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: ShimmerLoading(width: 120, height: 14)),
                  const ShimmerLoading(width: 60, height: 20),
                ],
              ),
              const SizedBox(height: 8),
              const ShimmerLoading(width: 80, height: 12),
              const SizedBox(height: 8),
              Row(
                children: [
                  const ShimmerLoading(width: 60, height: 12),
                  const Spacer(),
                  const ShimmerLoading(width: 60, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
