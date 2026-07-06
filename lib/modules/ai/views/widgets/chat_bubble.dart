import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/extensions.dart';
import 'package:taleem/data/models/ai_chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final AIChatMessage message;
  final bool isLast;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AIMessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 48.0 : 0,
        right: isUser ? 0 : 48.0,
        top: 4.0,
        bottom: isLast ? 4.0 : 4.0,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatarRow(context),
          const SizedBox(height: 4.0),
          _buildBubble(context, isUser),
          if (isLast) ...[
            const SizedBox(height: 4.0),
            _buildTimestamp(context, isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.smart_toy_rounded, size: 16.0, color: Colors.white),
        ),
        const SizedBox(width: 8.0),
        Text(
          'Taleem AI',
          style: AppTypography.labelCaps.copyWith(
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context, bool isUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.type == AIMessageType.text) {
      return _buildTextBubble(context, isUser, isDark);
    }

    if (message.type == AIMessageType.richCard) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextBubble(context, isUser, isDark),
          const SizedBox(height: 8.0),
          RichResponseCard(message: message),
        ],
      );
    }

    if (message.type == AIMessageType.chart) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextBubble(context, isUser, isDark),
          const SizedBox(height: 8.0),
          ResponseChart(message: message),
        ],
      );
    }

    if (message.type == AIMessageType.table) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextBubble(context, isUser, isDark),
          const SizedBox(height: 8.0),
          ResponseTable(message: message),
        ],
      );
    }

    return _buildTextBubble(context, isUser, isDark);
  }

  Widget _buildTextBubble(BuildContext context, bool isUser, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : (isDark ? AppColors.surfaceContainerHighDark : AppColors.surfaceContainerLow),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
          bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: SelectableText(
          message.content,
          style: isUser
              ? AppTypography.bodyMedium.copyWith(color: Colors.white)
              : AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, bool isUser) {
    return Text(
      message.timestamp.formatted(format: 'MMM dd, yyyy HH:mm'),
      style: AppTypography.labelCaps.copyWith(
        fontSize: 10.0,
        color: AppColors.outline,
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    Helpers.copyToClipboard(message.content, 'Message');
    HapticFeedback.lightImpact();
  }
}

class RichResponseCard extends StatelessWidget {
  final AIChatMessage message;

  const RichResponseCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final meta = message.metadata;
    if (meta == null) return const SizedBox.shrink();

    final type = meta['type'] as String? ?? '';

    if (type == 'attendance') {
      return _AttendanceCard(meta: meta);
    }
    if (type == 'fee') {
      return _FeeCard(meta: meta);
    }
    if (type == 'student') {
      return _StudentCard(meta: meta);
    }
    if (type == 'greeting') {
      return _SuggestionsList(meta: meta);
    }

    return const SizedBox.shrink();
  }
}

class _AttendanceCard extends StatelessWidget {
  final Map<String, dynamic> meta;
  const _AttendanceCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rate = (meta['rate'] as num?)?.toDouble() ?? 0;
    final present = meta['present'] ?? 0;
    final absent = meta['absent'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLowDark : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Rate', style: AppTypography.labelCaps),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rate >= 90 ? AppColors.secondary : AppColors.error,
                ),
              ),
              const Spacer(),
              _StatChip(label: 'Present', value: present.toString(), color: AppColors.secondary),
              const SizedBox(width: 8.0),
              _StatChip(label: 'Absent', value: absent.toString(), color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final Map<String, dynamic> meta;
  const _FeeCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final totalAmount = (meta['totalAmount'] as num?)?.toDouble() ?? 0;
    final totalPaid = (meta['totalPaid'] as num?)?.toDouble() ?? 0;
    final outstanding = (meta['outstanding'] as num?)?.toDouble() ?? 0;
    final rate = (meta['collectionRate'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fee Collection', style: AppTypography.labelCaps),
          const SizedBox(height: 8.0),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: rate >= 80 ? AppColors.secondary : AppColors.error,
            ),
          ),
          const SizedBox(height: 8.0),
          _MiniRow(label: 'Collected', value: totalPaid.toCurrency()),
          _MiniRow(label: 'Outstanding', value: outstanding.toCurrency()),
          _MiniRow(label: 'Total', value: totalAmount.toCurrency()),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> meta;
  const _StudentCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final total = meta['total'] ?? 0;
    final active = meta['active'] ?? 0;
    final inactive = meta['inactive'] ?? 0;
    final feePending = meta['feePending'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Overview', style: AppTypography.labelCaps),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            children: [
              _MiniStat(label: 'Total', value: total.toString(), color: AppColors.primary),
              _MiniStat(label: 'Active', value: active.toString(), color: AppColors.secondary),
              _MiniStat(label: 'Inactive', value: inactive.toString(), color: AppColors.outline),
              _MiniStat(label: 'Fee Pending', value: feePending.toString(), color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  final Map<String, dynamic> meta;
  const _SuggestionsList({required this.meta});

  @override
  Widget build(BuildContext context) {
    final suggestions = meta['suggestions'] as List<dynamic>? ?? [];
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Try asking:', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8.0),
          ...suggestions.take(4).map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text('• $s', style: AppTypography.bodySmall),
          )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.labelCaps.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4.0),
          Text(label, style: AppTypography.labelCaps.copyWith(color: color, fontSize: 10.0)),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final String label;
  final String value;
  const _MiniRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.regular),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10.0)),
        ],
      ),
    );
  }
}

class ResponseChart extends StatelessWidget {
  final AIChatMessage message;
  const ResponseChart({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final meta = message.metadata;
    if (meta == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final datasets = meta['datasets'] as List<dynamic>? ?? [];
    final labels = meta['labels'] as List<dynamic>? ?? [];

    if (datasets.isEmpty) return const SizedBox.shrink();

    final data = (datasets.first['data'] as List<dynamic>?)?.cast<num>() ?? [];
    final colorHex = datasets.first['color'] as String? ?? '#2C2ABC';
    final chartColor = Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16));
    final maxVal = data.isEmpty ? 100.0 : data.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLowDark : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meta['title'] as String? ?? 'Chart', style: AppTypography.labelCaps),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 140.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final val = data[i].toDouble();
                final height = maxVal > 0 ? (val / maxVal) * 120.0 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          val.toStringAsFixed(0),
                          style: AppTypography.labelCaps.copyWith(fontSize: 8.0, color: AppColors.outline),
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          height: height.clamp(4.0, 120.0),
                          decoration: BoxDecoration(
                            color: chartColor.withValues(alpha: 0.7 + (i / data.length) * 0.3),
                            borderRadius: BorderRadius.circular(4.0),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                chartColor.withValues(alpha: 0.4),
                                chartColor,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          i < labels.length ? labels[i].toString() : '',
                          style: AppTypography.labelCaps.copyWith(fontSize: 8.0, color: AppColors.outline),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponseTable extends StatelessWidget {
  final AIChatMessage message;
  const ResponseTable({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLowDark : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Data', style: AppTypography.labelCaps),
          const SizedBox(height: 12.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _parseTable(message.content),
          ),
        ],
      ),
    );
  }

  Widget _parseTable(String content) {
    final lines = content.split('\n');
    final tableLines = <List<String>>[];
    bool inTable = false;

    for (final line in lines) {
      if (line.trimLeft().startsWith('|') && line.trimRight().endsWith('|')) {
        final cells = line.split('|')
            .where((c) => c.trim().isNotEmpty)
            .map((c) => c.trim().replaceAll(RegExp(r'[*]'), ''))
            .toList();
        if (cells.isNotEmpty) {
          tableLines.add(cells);
        }
        inTable = true;
      } else if (inTable && tableLines.isNotEmpty) {
        break;
      }
    }

    if (tableLines.isEmpty || tableLines.length < 2) {
      return Text(message.content, style: AppTypography.bodySmall);
    }

    return Table(
      border: TableBorder.all(color: AppColors.outlineVariant.withValues(alpha: 0.3), width: 0.5),
      columnWidths: _buildColumnWidths(tableLines.first.length),
      children: tableLines.asMap().entries.map((entry) {
        final isHeader = entry.key == 0;
        return TableRow(
          decoration: BoxDecoration(
            color: isHeader ? AppColors.primary.withValues(alpha: 0.08) : null,
          ),
          children: entry.value.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell,
                style: (isHeader ? AppTypography.labelCaps : AppTypography.bodySmall).copyWith(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths(int count) {
    final widths = <int, TableColumnWidth>{};
    for (int i = 0; i < count; i++) {
      widths[i] = const FlexColumnWidth(1.0);
    }
    return widths;
  }
}
