import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// The current state of the voice input session.
enum VoiceInputState { idle, listening, processing }

enum VoiceInitStatus { success, permissionDenied, notAvailable }

/// Controls voice input for any text field in the app.
///
/// Field-agnostic — reusable for title, description, search, AI prompts.
class VoiceInputController {
  VoiceInputController({this.localeId = 'ar-EG'});

  final String localeId;
  final SpeechToText _stt = SpeechToText();

  bool _initialized = false;
  VoiceInputState _state = VoiceInputState.idle;

  bool get isListening => _state == VoiceInputState.listening;
  bool get isIdle => _state == VoiceInputState.idle;
  VoiceInputState get state => _state;

  // ── Permissions (must come BEFORE initialize on Android) ─────

  Future<bool> _ensurePermissions() async {
    // On Android, RECORD_AUDIO must be granted before SpeechToText.initialize()
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;

    if (Platform.isIOS) {
      final speech = await Permission.speech.request();
      if (!speech.isGranted) return false;
    }
    return true;
  }

  // ── Init ─────────────────────────────────────────────────────

  Future<VoiceInitStatus> _initIfNeeded() async {
    // If already initialised and still available, skip.
    if (_initialized && _stt.isAvailable) return VoiceInitStatus.success;

    // Step 1: permissions first
    final permitted = await _ensurePermissions();
    if (!permitted) return VoiceInitStatus.permissionDenied;

    // Step 2: initialise the engine
    _initialized = await _stt.initialize(
      debugLogging: kDebugMode,
      onStatus: (s) => debugPrint('[Voice] status: $s'),
      onError: (e) => debugPrint('[Voice] error: ${e.errorMsg}'),
    );

    debugPrint('[Voice] initialized=$_initialized available=${_stt.isAvailable}');
    return (_initialized && _stt.isAvailable) ? VoiceInitStatus.success : VoiceInitStatus.notAvailable;
  }

  // ── Listening ────────────────────────────────────────────────

  Future<void> startListening({
    required void Function(String words, {required bool isFinal}) onResult,
    required void Function(VoiceInputState state) onStateChanged,
    required void Function(String message, {bool isPermissionPermanentlyDenied}) onError,
    bool pushToTalk = false,
  }) async {
    if (_state != VoiceInputState.idle) return;

    final status = await _initIfNeeded();
    
    if (status == VoiceInitStatus.permissionDenied) {
      onError(
        'إذن الميكروفون مطلوب لاستخدام ميزة الإدخال الصوتي.',
        isPermissionPermanentlyDenied: true, // Always show the dialog if permission is denied
      );
      return;
    } else if (status == VoiceInitStatus.notAvailable) {
      onError(
        'عذراً، ميزة التعرف على الصوت غير متوفرة على هذا الجهاز.',
        isPermissionPermanentlyDenied: false,
      );
      return;
    }

    _state = VoiceInputState.listening;
    onStateChanged(_state);

    await _stt.listen(
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        listenMode:
            pushToTalk ? ListenMode.dictation : ListenMode.confirmation,
        cancelOnError: false,
        partialResults: true,
      ),
      onResult: (SpeechRecognitionResult result) {
        final words = result.recognizedWords.trim();
        if (result.finalResult) {
          _state = VoiceInputState.idle;
          onStateChanged(_state);
        }
        onResult(words, isFinal: result.finalResult);
      },
    );
  }

  Future<void> stopListening() async {
    if (_state != VoiceInputState.listening) return;
    await _stt.stop();
    _state = VoiceInputState.idle;
  }

  Future<void> cancel() async {
    await _stt.cancel();
    _state = VoiceInputState.idle;
  }

  void dispose() {
    _stt.cancel();
  }
}
