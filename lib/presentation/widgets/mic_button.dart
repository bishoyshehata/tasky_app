import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An animated microphone suffix icon for text fields.
///
/// Features:
///   - Pulse animation when listening
///   - Short tap → untilSilence mode
///   - Long press → push-to-talk (untilStopped) mode
///   - Haptic feedback on start/stop
///   - Glow ring while listening
///   - Semantic label for accessibility
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.isListening,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    this.semanticLabel = 'Voice input',
  });

  final bool isListening;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final String semanticLabel;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !old.isListening) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isListening && old.isListening) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color =
        widget.isListening ? cs.error : cs.onSurfaceVariant;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onLongPressStart: (_) {
          HapticFeedback.mediumImpact();
          widget.onLongPressStart();
        },
        onLongPressEnd: (_) {
          HapticFeedback.lightImpact();
          widget.onLongPressEnd();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring
                  if (widget.isListening)
                    Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.error.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  // Icon
                  Transform.scale(
                    scale: widget.isListening ? _scaleAnim.value : 1.0,
                    child: child!,
                  ),
                ],
              );
            },
            child: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none_outlined,
              size: 22,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
