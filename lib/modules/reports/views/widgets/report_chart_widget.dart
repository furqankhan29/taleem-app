import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';

class ReportChartWidget extends StatelessWidget {
  final Map<String, dynamic> chart;
  final double height;

  const ReportChartWidget({
    super.key,
    required this.chart,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final type = chart['type'] as String? ?? 'bar';
    final title = chart['title'] as String? ?? '';
    final labels = (chart['labels'] as List?)?.cast<String>() ?? [];
    final datasets = (chart['datasets'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: height - 80,
            child: type == 'pie'
                ? _buildPieChart(datasets, labels)
                : _buildBarChart(datasets, labels),
          ),
          if (type != 'pie' && datasets.length > 1) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: datasets.map((d) {
                final color = d['color'] as String? ?? '#2C2ABC';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(d['label'] as String? ?? '', style: AppTypography.labelCaps),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> datasets, List<String> labels) {
    return CustomPaint(
      size: Size.infinite,
      painter: _BarChartPainter(datasets, labels),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> datasets, List<String> labels) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomPaint(
            size: const Size.fromHeight(180),
            painter: _PieChartPainter(datasets),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: labels.asMap().entries.map((entry) {
              final idx = entry.key;
              final colors = (datasets.isNotEmpty ? datasets.first['colors'] : null) as List? ?? [];
              final colorStr = idx < colors.length ? colors[idx] as String : '#2C2ABC';
              final dataValues = (datasets.isNotEmpty ? datasets.first['data'] : null) as List? ?? [];
              final value = idx < dataValues.length ? dataValues[idx] : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: _parseColor(colorStr),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${entry.value}: ', style: AppTypography.labelCaps),
                    Text('${(value as num?)?.toStringAsFixed(1) ?? '0'}%', style: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> datasets;
  final List<String> labels;

  _BarChartPainter(this.datasets, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty || datasets.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const padding = 40.0;
    const barSpacing = 8.0;
    final chartWidth = size.width - padding;
    final chartHeight = size.height - padding;
    final barWidth = (chartWidth / labels.length - barSpacing) / datasets.length;

    double maxVal = 0;
    for (final d in datasets) {
      final data = (d['data'] as List?)?.cast<num>() ?? [];
      for (final v in data) {
        if (v.toDouble() > maxVal) maxVal = v.toDouble();
      }
    }
    if (maxVal == 0) maxVal = 100;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * (1 - i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < labels.length; i++) {
      final x = padding + i * (chartWidth / labels.length);
      for (int j = 0; j < datasets.length; j++) {
        final data = (datasets[j]['data'] as List?)?.cast<num>() ?? [];
        final val = i < data.length ? data[i].toDouble() : 0.0;
        final barH = (val / maxVal) * chartHeight;
        final color = datasets[j]['color'] as String? ?? '#2C2ABC';

        paint.color = _parseColor(color).withValues(alpha: 0.8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + j * (barWidth + 2), padding + chartHeight - barH, barWidth, barH),
            const Radius.circular(4),
          ),
          paint,
        );
      }

      // Label
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth * datasets.length) / 2 - textPainter.width / 2, size.height - textPainter.height),
      );
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> datasets;

  _PieChartPainter(this.datasets);

  @override
  void paint(Canvas canvas, Size size) {
    if (datasets.isEmpty) return;

    final data = (datasets.first['data'] as List?)?.cast<num>() ?? [];
    final colors = (datasets.first['colors'] as List?)?.cast<String>() ?? [];
    if (data.isEmpty) return;

    final total = data.fold<num>(0, (a, b) => a + b).toDouble();
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 10;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -90 * (3.14159 / 180);
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].toDouble() / total) * 360 * (3.14159 / 180);
      final color = i < colors.length ? colors[i] : '#2C2ABC';
      paint.color = _parseColor(color);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
