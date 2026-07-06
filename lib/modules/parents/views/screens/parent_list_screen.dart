import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/modules/parents/controllers/parent_controller.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/responsive_layout.dart';
import 'package:taleem/shared/widgets/search_field.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';

class ParentListScreen extends StatefulWidget {
  const ParentListScreen({super.key});

  @override
  State<ParentListScreen> createState() => _ParentListScreenState();
}

class _ParentListScreenState extends State<ParentListScreen> {
  final ParentController controller = Get.find<ParentController>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortSheet(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: (_) => _buildContent(context),
        desktop: (_) => _buildContent(context),
      ),
    );
  }

  void _showSortSheet() {
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
          children: [
            Text('Sort By', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha_rounded),
              title: const Text('Name'),
              trailing: controller.sortByField.value == 'name' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { controller.updateSorting('name', false); Get.back(); },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Recently Added'),
              trailing: controller.sortByField.value == 'createdAt' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { controller.updateSorting('createdAt', true); Get.back(); },
            ),
          ],
        ),
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
                    hint: 'Search parents...',
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.parentDetail, arguments: null),
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
                    icon: Icons.people_outline_rounded,
                    title: 'No Parents Found',
                    subtitle: 'Add a parent to get started.',
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
                        final parent = controller.items[index];
                        return _buildParentCard(parent);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildParentCard(ParentModel parent) {
    final hasStudents = parent.studentIds.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Get.toNamed(AppRoutes.parentDetail, arguments: parent),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: parent.photoUrl,
              name: parent.name,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parent.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (parent.relation != null)
                        Text(
                          parent.relation!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      if (parent.relation != null && parent.phone != null)
                        Text(' | ', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                      if (parent.phone != null)
                        Text(
                          parent.phone!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.group_rounded, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        hasStudents ? '${parent.studentIds.length} linked students' : 'No linked students',
                        style: AppTypography.labelCaps.copyWith(
                          color: hasStudents ? AppColors.onSurfaceVariant : AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
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
          child: Row(
            children: [
              const ShimmerLoading(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(width: 150, height: 14),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: 120, height: 12),
                    const SizedBox(height: 6),
                    const ShimmerLoading(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
