import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'voice_state.dart';
import 'voice_events.dart';
import 'voice_input_service.dart';

/// Clean architecture controller for managing voice states and dispatching voice events.
class VoiceInputController extends ValueNotifier<VoiceState> {
  final VoiceInputService _service;
  final String defaultLocale;

  VoiceInputController({
    VoiceInputService? service,
    this.defaultLocale = 'ar-EG',
  })  : _service = service ?? TalkItVoiceInputService(),
        super(const VoiceState());

  bool _initialized = false;

  Future<void> dispatchEvent(VoiceEvent event) async {
    if (event is VoiceEventInit) {
      await _initialize();
    } else if (event is VoiceEventStartListening) {
      await _startListening(event.isPushToTalk, localeId: event.localeId);
    } else if (event is VoiceEventStopListening) {
      await _stopListening();
    } else if (event is VoiceEventCancelListening) {
      await _cancelListening();
    } else if (event is VoiceEventReset) {
      _reset();
    }
  }

  Future<bool> _ensurePermissions() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mic.isPermanentlyDenied) {
        value = value.copyWith(isPermissionPermanentlyDenied: true);
      }
      return false;
    }

    if (Platform.isIOS) {
      final speech = await Permission.speech.request();
      if (!speech.isGranted) {
        if (speech.isPermanentlyDenied) {
          value = value.copyWith(isPermissionPermanentlyDenied: true);
        }
        return false;
      }
    }
    value = value.copyWith(isPermissionPermanentlyDenied: false);
    return true;
  }

  Future<void> _initialize() async {
    if (value.status == VoiceStatus.initializing) return;
    value = value.copyWith(status: VoiceStatus.initializing, errorMessage: null);

    final permitted = await _ensurePermissions();
    if (!permitted) {
      value = value.copyWith(
        status: VoiceStatus.failure,
        errorMessage: 'إذن الميكروفون مطلوب لاستخدام ميزة الإدخال الصوتي.',
      );
      return;
    }

    final success = await _service.initialize();
    if (success && _service.isAvailable) {
      _initialized = true;
      value = value.copyWith(
        status: VoiceStatus.idle,
        isAvailable: true,
      );
    } else {
      _initialized = false;
      value = value.copyWith(
        status: VoiceStatus.failure,
        isAvailable: false,
        errorMessage: 'ميزة التعرف على الصوت غير متوفرة على هذا الجهاز.',
      );
    }
  }

  Future<void> _startListening(bool isPushToTalk, {String? localeId}) async {
    if (value.status == VoiceStatus.listening) return;

    if (!_initialized) {
      await _initialize();
      if (!_initialized) return;
    }

    // Double check permissions (e.g. they returned from settings)
    final permitted = await _ensurePermissions();
    if (!permitted) {
      value = value.copyWith(
        status: VoiceStatus.failure,
        errorMessage: 'إذن الميكروفون مطلوب لاستخدام ميزة الإدخال الصوتي.',
      );
      return;
    }

    value = value.copyWith(
      status: VoiceStatus.listening,
      lastWords: '',
      errorMessage: null,
    );

    await _service.listen(
      localeId: localeId ?? defaultLocale,
      isPushToTalk: isPushToTalk,
      onResult: (text, isFinal) {
        if (isFinal) {
          value = value.copyWith(
            status: VoiceStatus.success,
            lastWords: text.trim(),
          );
        } else {
          value = value.copyWith(
            lastWords: text.trim(),
          );
        }
      },
      onError: (errorMsg) {
        value = value.copyWith(
          status: VoiceStatus.failure,
          errorMessage: _cleanErrorMsg(errorMsg),
        );
      },
    );
  }

  String _cleanErrorMsg(String errorMsg) {
    final lower = errorMsg.toLowerCase();
    if (lower.contains('no match') || lower.contains('error_no_match')) {
      return 'لم يتم اكتشاف أي كلام. يرجى المحاولة مجدداً.';
    } else if (lower.contains('timeout') || lower.contains('error_speech_timeout')) {
      return 'انتهت مهلة التحدث دون اكتشاف صوت.';
    } else if (lower.contains('busy') || lower.contains('error_busy')) {
      return 'المحرك مشغول حالياً. يرجى الانتظار.';
    } else if (lower.contains('unavailable') || lower.contains('not_available')) {
      return 'التعرف على الصوت غير متوفر على هذا الجهاز.';
    }
    return 'حدث خطأ أثناء التعرف على الصوت: $errorMsg';
  }

  Future<void> _stopListening() async {
    if (value.status != VoiceStatus.listening) return;
    value = value.copyWith(status: VoiceStatus.processing);
    await _service.stop();
  }

  Future<void> _cancelListening() async {
    await _service.cancel();
    value = value.copyWith(status: VoiceStatus.idle, lastWords: '');
  }

  void _reset() {
    value = const VoiceState();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
