import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_shadows.dart';

class CustomFab extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String? heroTag;

  const CustomFab({
    super.key,
    required this.onTap,
    this.icon = Icons.add_rounded,
    this.heroTag,
  });

  @override
  State<CustomFab> createState() => _CustomFabState();
}

class _CustomFabState extends State<CustomFab> {
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.ambientShadow,
      ),
      child: FloatingActionButton(
        heroTag: widget.heroTag,
        onPressed: () {
          setState(() {
            _rotation = _rotation == 0.0 ? 0.25 : 0.0; // 90 degree rotation (0.25 of a full turn)
          });
          widget.onTap();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: AnimatedRotation(
          turns: _rotation,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Icon(
            widget.icon,
            size: 28.0,
          ),
        ),
      ),
    );
  }
}
