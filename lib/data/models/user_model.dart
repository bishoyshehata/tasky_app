class UserModel {
  final String name;
  final String? motivationQuote;
  final String? profileImagePath;

  UserModel({required this.name, this.motivationQuote, this.profileImagePath});

  UserModel copyWith({
    String? name,
    String? motivationQuote,
    String? profileImagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      motivationQuote: motivationQuote ?? this.motivationQuote,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'motivationQuote': motivationQuote,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      motivationQuote: json['motivationQuote'],
      profileImagePath: json['profileImagePath'],
    );
  }
}
