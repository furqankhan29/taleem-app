import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: widget.isTyping
          ? Padding(
              padding: const EdgeInsets.only(left: 0, top: 4.0, bottom: 8.0),
              child: Row(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceContainerHighDark
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return _AnimatedDot(
                          listenable: _controller,
                          index: index,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _AnimatedDot extends AnimatedWidget {
  final int index;

  const _AnimatedDot({
    required super.listenable,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<double>;
    final delay = index * 0.15;
    final t = (animation.value - delay).clamp(0.0, 1.0);
    final scale = 0.4 + 0.6 * (1 - (t * 4 - 1).abs().clamp(0.0, 1.0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
