import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/core/utils/formatters.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40.0,
    this.borderWidth = 0.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final initials = Formatters.getInitials(name);

    Widget avatarChild;

    if (hasImage) {
      avatarChild = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildInitialsPlaceholder(initials),
        errorWidget: (context, url, error) => _buildInitialsPlaceholder(initials),
      );
    } else {
      avatarChild = _buildInitialsPlaceholder(initials);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: avatarChild,
      ),
    );
  }

  Widget _buildInitialsPlaceholder(String initials) {
    // Generate a consistent color based on name hash
    final colorIndex = name.hashCode % _avatarColors.length;
    final bgColor = _avatarColors[colorIndex];

    return Container(
      width: size,
      height: size,
      color: bgColor.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.labelCaps.copyWith(
          color: bgColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static const List<Color> _avatarColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    Color(0xFFE28743),
    Color(0xFF76B5C5),
    Color(0xFF873E23),
    Color(0xFF1E3D59),
    Color(0xFF15B53B),
  ];
}
