import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';

class VoiceInputButton extends StatefulWidget {
  final VoidCallback? onResult;
  final bool isListening;

  const VoiceInputButton({
    super.key,
    this.onResult,
    this.isListening = false,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.isListening ? 1.0 + _pulseController.value * 0.15 : 1.0;

        return GestureDetector(
          onTap: widget.onResult,
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: widget.isListening ? AppColors.error : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: widget.isListening
                    ? [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.3),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: widget.isListening ? Colors.white : AppColors.onSurfaceVariant,
                size: 22.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
