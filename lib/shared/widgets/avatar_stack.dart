import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';

class AvatarStack extends StatelessWidget {
  final List<String> imageUrls;
  final int maxDisplay;
  final double size;
  final double overlap;

  const AvatarStack({
    super.key,
    required this.imageUrls,
    this.maxDisplay = 3,
    this.size = 24.0,
    this.overlap = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final count = imageUrls.length;
    final displayCount = count > maxDisplay ? maxDisplay : count;
    final hasOverflow = count > maxDisplay;
    final overflowCount = count - maxDisplay;

    final children = <Widget>[];

    for (var i = 0; i < displayCount; i++) {
      children.add(
        Positioned(
          left: i * (size - overlap),
          child: AvatarWidget(
            imageUrl: imageUrls[i],
            name: 'Student $i',
            size: size,
            borderWidth: 1.0,
            borderColor: Colors.white,
          ),
        ),
      );
    }

    if (hasOverflow) {
      children.add(
        Positioned(
          left: displayCount * (size - overlap),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '+$overflowCount',
              style: AppTypography.labelCaps.copyWith(
                fontSize: size * 0.4,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    final totalWidth = (displayCount * (size - overlap)) + (hasOverflow ? size : overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: children,
      ),
    );
  }
}
