class User {
  final String id;
  final String name;
  final String email;
  final String birthdate;
  final String bio;
  final String gender;
  final String avatarUrl;
  final bool isActive;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.birthdate,
    this.bio = '',
    this.gender = '',
    this.avatarUrl = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      name: row['name'] as String,
      email: row['email'] as String,
      birthdate: row['birthdate'] as String,
      bio: (row['bio'] as String?) ?? '',
      gender: (row['gender'] as String?) ?? '',
      avatarUrl: (row['avatar_url'] as String?) ?? '',
      isActive: (row['is_active'] as int) == 1,
      createdAt: row['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthdate': birthdate,
      'bio': bio,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
