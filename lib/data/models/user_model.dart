import 'dart:io';

class UserModel {
  final String name;
  final String? motivationQuote;
  final File? profileImage;

  UserModel({required this.name, this.motivationQuote, this.profileImage});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      motivationQuote: json['motivationQuote'],
      profileImage: json['profileImage'] != null
          ? File(json['profileImage'])
          : null,
    );
  }

  // convert UserModel to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'motivationQuote': motivationQuote,
      'profileImage': profileImage,
    };
  }
}
