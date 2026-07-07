import 'package:talk_it/talk_it.dart';

abstract class VoiceInputService {
  Future<bool> initialize();
  Future<void> listen({
    required void Function(String text, bool isFinal) onResult,
    required void Function(String errorMsg) onError,
    String? localeId,
    bool isPushToTalk = false,
  });
  Future<void> stop();
  Future<void> cancel();
  bool get isListening;
  bool get isAvailable;
  void dispose();
}

class TalkItVoiceInputService implements VoiceInputService {
  final TalkIt _talkIt = TalkIt();

  @override
  Future<bool> initialize() async {
    return await _talkIt.initialize();
  }

  @override
  Future<void> listen({
    required void Function(String text, bool isFinal) onResult,
    required void Function(String errorMsg) onError,
    String? localeId,
    bool isPushToTalk = false,
  }) async {
    try {
      await _talkIt.listen(
        localeId: localeId,
        listenOptions: TalkItListenOptions(
          mode: isPushToTalk ? TalkItMode.untilStopped : TalkItMode.untilSilence,
        ),
        onResult: (result) {
          onResult(result.recognizedWords, result.isFinal);
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  Future<void> stop() async {
    await _talkIt.stop();
  }

  @override
  Future<void> cancel() async {
    await _talkIt.cancel();
  }

  @override
  bool get isListening => _talkIt.isListening;

  @override
  bool get isAvailable => _talkIt.isAvailable;

  @override
  void dispose() {
    // talk_it does not expose a dispose method directly.
  }
}
