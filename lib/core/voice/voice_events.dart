import 'package:flutter/foundation.dart';

@immutable
abstract class VoiceEvent {
  const VoiceEvent();
}

class VoiceEventInit extends VoiceEvent {
  const VoiceEventInit();
}

class VoiceEventStartListening extends VoiceEvent {
  final bool isPushToTalk;
  final String? localeId;
  const VoiceEventStartListening({this.isPushToTalk = false, this.localeId});
}

class VoiceEventStopListening extends VoiceEvent {
  const VoiceEventStopListening();
}

class VoiceEventCancelListening extends VoiceEvent {
  const VoiceEventCancelListening();
}

class VoiceEventReset extends VoiceEvent {
  const VoiceEventReset();
}
