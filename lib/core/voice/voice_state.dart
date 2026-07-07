import 'package:flutter/foundation.dart';

enum VoiceStatus {
  idle,
  initializing,
  listening,
  processing,
  success,
  failure,
}

@immutable
class VoiceState {
  final VoiceStatus status;
  final String lastWords;
  final String? errorMessage;
  final bool isAvailable;
  final bool isPermissionPermanentlyDenied;

  const VoiceState({
    this.status = VoiceStatus.idle,
    this.lastWords = '',
    this.errorMessage,
    this.isAvailable = false,
    this.isPermissionPermanentlyDenied = false,
  });

  VoiceState copyWith({
    VoiceStatus? status,
    String? lastWords,
    String? errorMessage,
    bool? isAvailable,
    bool? isPermissionPermanentlyDenied,
  }) {
    return VoiceState(
      status: status ?? this.status,
      lastWords: lastWords ?? this.lastWords,
      errorMessage: errorMessage ?? this.errorMessage,
      isAvailable: isAvailable ?? this.isAvailable,
      isPermissionPermanentlyDenied: isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
    );
  }

  @override
  String toString() {
    return 'VoiceState(status: $status, lastWords: $lastWords, error: $errorMessage, available: $isAvailable, permanentlyDenied: $isPermissionPermanentlyDenied)';
  }
}
