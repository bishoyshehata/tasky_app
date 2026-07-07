import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/voice/voice_input_controller.dart';
import '../../core/voice/voice_state.dart';
import '../../core/voice/voice_events.dart';
import '../../core/voice/voice_input_service.dart';

class VoiceInputBottomSheet extends StatefulWidget {
  final String title;
  final bool initialPushToTalk;
  final String localeId;

  const VoiceInputBottomSheet({
    super.key,
    required this.title,
    this.initialPushToTalk = false,
    this.localeId = 'ar-EG',
  });

  /// Opens the bottom sheet and returns the final transcribed text.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    bool initialPushToTalk = false,
    String localeId = 'ar-EG',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => VoiceInputBottomSheet(
        title: title,
        initialPushToTalk: initialPushToTalk,
        localeId: localeId,
      ),
    );
  }

  @override
  State<VoiceInputBottomSheet> createState() => _VoiceInputBottomSheetState();
}

class _VoiceInputBottomSheetState extends State<VoiceInputBottomSheet>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final VoiceInputController _controller;
  late final AnimationController _waveController;
  late bool _isPushToTalk;
  late String _selectedLocale;

  // Track if we redirected the user to settings to request auto-resume on return
  bool _wasRedirectedToSettings = false;

  // Silence detection fields
  Timer? _silenceTimer;
  String _previousLastWords = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isPushToTalk = false;
    _selectedLocale = widget.localeId;

    _controller = VoiceInputController(
      service: TalkItVoiceInputService(),
      defaultLocale: _selectedLocale,
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _controller.addListener(_onStateChanged);

    // Initialise and start listening immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningFlow();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _waveController.dispose();
    _silenceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasRedirectedToSettings) {
      _wasRedirectedToSettings = false;
      _checkPermissionAndResume();
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});

      // Custom silence detection for "Until Silence" mode
      if (!_isPushToTalk && _controller.value.status == VoiceStatus.listening) {
        final currentWords = _controller.value.lastWords;
        if (currentWords.isNotEmpty) {
          if (currentWords != _previousLastWords) {
            _previousLastWords = currentWords;
            _resetSilenceTimer();
          }
        }
      } else {
        _silenceTimer?.cancel();
        _silenceTimer = null;
      }

      // Close sheet on success state
      if (_controller.value.status == VoiceStatus.success) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(_controller.value.lastWords);
      }
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _controller.value.status == VoiceStatus.listening) {
        HapticFeedback.mediumImpact();
        _controller.dispatchEvent(const VoiceEventStopListening());
      }
    });
  }

  Future<void> _startListeningFlow() async {
    HapticFeedback.mediumImpact();
    await _controller.dispatchEvent(const VoiceEventInit());

    if (_controller.value.isPermissionPermanentlyDenied) {
      _showPermissionRequiredDialog();
      return;
    }

    if (_controller.value.status == VoiceStatus.idle) {
      // Under the hood, we ALWAYS run talk_it in continuous mode (isPushToTalk: true)
      // to prevent the native speech engine from timing out/cutting off prematurely on brief pauses.
      // Silence detection is handled reliably on the Flutter side via the _silenceTimer.
      _controller.dispatchEvent(VoiceEventStartListening(
        isPushToTalk: true,
        localeId: _selectedLocale,
      ));
    }
  }

  Future<void> _checkPermissionAndResume() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      _controller.dispatchEvent(const VoiceEventReset());
      _startListeningFlow();
    }
  }

  void _showPermissionRequiredDialog() {
    final isAr = _selectedLocale.startsWith('ar');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'مطلوب إذن الميكروفون' : 'Microphone Permission Required',
          textAlign: isAr ? TextAlign.right : TextAlign.left,
        ),
        content: Text(
          isAr
              ? 'يتطلب الإدخال الصوتي الوصول إلى الميكروفون. يرجى تفعيل الإذن من إعدادات التطبيق للمتابعة.'
              : 'Voice input requires microphone access. Please allow microphone permission from the app settings, then return to continue.',
          textAlign: isAr ? TextAlign.right : TextAlign.left,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _wasRedirectedToSettings = true;
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isAr ? 'فتح الإعدادات' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  void _toggleLanguage() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLocale = _selectedLocale.startsWith('ar') ? 'en-US' : 'ar-EG';
      _previousLastWords = '';
    });
    _silenceTimer?.cancel();
    _silenceTimer = null;
    
    // Restart listening with the new language
    _controller.dispatchEvent(const VoiceEventCancelListening());
    _controller.dispatchEvent(VoiceEventStartListening(
      isPushToTalk: true,
      localeId: _selectedLocale,
    ));
  }



  void _toggleListening() {
    final status = _controller.value.status;
    if (status == VoiceStatus.listening) {
      HapticFeedback.mediumImpact();
      _controller.dispatchEvent(const VoiceEventStopListening());
    } else {
      _startListeningFlow();
    }
  }

  String _getStatusText() {
    final isAr = _selectedLocale.startsWith('ar');
    final status = _controller.value.status;

    switch (status) {
      case VoiceStatus.initializing:
        return isAr ? 'جاري التهيئة...' : 'Initializing...';
      case VoiceStatus.listening:
        return isAr ? 'جاري الاستماع...' : 'Listening...';
      case VoiceStatus.processing:
        return isAr ? 'جاري المعالجة...' : 'Processing...';
      case VoiceStatus.success:
        return isAr ? 'تم بنجاح!' : 'Success!';
      case VoiceStatus.failure:
        return _controller.value.errorMessage ?? (isAr ? 'فشل التسجيل' : 'Recording failed');
      case VoiceStatus.idle:
        return isAr ? 'اضغط للبدء' : 'Tap to start';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = _selectedLocale.startsWith('ar');
    final isListening = _controller.value.status == VoiceStatus.listening;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Language Toggle
            Row(
              children: [
                const SizedBox(width: 48), // Spacer to balance the translate button
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _toggleLanguage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedLocale.startsWith('ar') ? 'العربية' : 'English',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),



            // Live Transcript Box
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _controller.value.lastWords.isEmpty
                      ? (isListening
                          ? (isAr ? 'تحدث الآن...' : 'Speak now...')
                          : (isAr ? 'اضغط على المايك وابدأ التحدث' : 'Tap mic and start speaking'))
                      : _controller.value.lastWords,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _controller.value.lastWords.isEmpty
                        ? (isDark ? Colors.white30 : Colors.black38)
                        : (isDark ? Colors.white : Colors.black87),
                    height: 1.5,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Listening status message
            Text(
              _getStatusText(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _controller.value.status == VoiceStatus.failure
                    ? theme.colorScheme.error
                    : (isDark ? Colors.white60 : Colors.black54),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Center area: Pulsing Mic & Waveforms
            Stack(
              alignment: Alignment.center,
              children: [
                if (isListening)
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 140,
                        height: 140,
                        child: CustomPaint(
                          painter: _MicRipplePainter(
                            progress: _waveController.value,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white12 : Colors.grey[200]),
                      boxShadow: isListening
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 4,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      size: 32,
                      color: isListening
                          ? theme.colorScheme.onPrimary
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _controller.dispatchEvent(const VoiceEventCancelListening());
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isAr ? 'إلغاء' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isListening || _controller.value.lastWords.isNotEmpty
                        ? () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop(_controller.value.lastWords);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(isAr ? 'تأكيد' : 'Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



/// Custom painter to draw glowing concentric ripple rings around the microphone
class _MicRipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _MicRipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 3; i >= 1; i--) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = maxRadius * ringProgress;
      final opacity = (1.0 - ringProgress) * 0.45;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (3.0 * (1.0 - ringProgress));

      canvas.drawCircle(center, radius, paint);

      // Draw subtle solid fill
      final fillPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MicRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
