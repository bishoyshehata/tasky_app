import 'dart:convert';
import 'dart:typed_data';

class UserModel {
  final String name;
  final String? motivationQuote;
  final String? profileImageBase64;
  Uint8List? _profileImageBytes;

  UserModel({required this.name, this.motivationQuote, this.profileImageBase64}) {
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      try {
        _profileImageBytes = base64Decode(profileImageBase64!);
      } catch (_) {
        _profileImageBytes = null;
      }
    }
  }

  Uint8List? get profileImageBytes => _profileImageBytes;

  UserModel copyWith({
    String? name,
    String? motivationQuote,
    String? profileImageBase64,
  }) {
    return UserModel(
      name: name ?? this.name,
      motivationQuote: motivationQuote ?? this.motivationQuote,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'motivationQuote': motivationQuote,
      'profileImageBase64': profileImageBase64,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      motivationQuote: json['motivationQuote'],
      profileImageBase64: json['profileImageBase64'],
    );
  }
}
