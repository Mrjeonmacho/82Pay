class ProfileUserModel {
  final String name;
  final String email;
  final String language;

  const ProfileUserModel({
    required this.name,
    required this.email,
    required this.language,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      language: json['language'] ?? 'English',
    );
  }
}