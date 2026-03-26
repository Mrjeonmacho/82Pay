class ProfileUserModel {
  final int userId;
  final String name;
  final String email;
  final String countryCode;
  final String? language; // 선택 사항

  ProfileUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.countryCode,
    this.language,
  });

  // 💡 JSON 변환 로직 (백엔드 userInfo 규격에 맞춤)
  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      countryCode: json['countryCode'],
      language: json['language'] ?? 'English',
    );
  }
}