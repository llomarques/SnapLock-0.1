class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String birthdate;
  final String bio;
  final String gender;
  final String avatarUrl;
  final String friendshipStatus;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    this.username = '',
    required this.email,
    required this.birthdate,
    this.bio = '',
    this.gender = '',
    this.avatarUrl = '',
    this.friendshipStatus = '',
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: (json['username'] as String?) ?? '',
      email: json['email'] as String,
      birthdate: (json['birthdate'] as String?) ?? '',
      bio: (json['bio'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      avatarUrl: (json['avatarUrl'] as String?) ?? (json['avatar_url'] as String?) ?? '',
      friendshipStatus: (json['friendshipStatus'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'birthdate': birthdate,
      'bio': bio,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'friendshipStatus': friendshipStatus,
      'isActive': isActive,
    };
  }
}
