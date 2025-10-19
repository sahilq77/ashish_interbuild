

class User  {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  // Factory method to create a user from JSON (e.g., API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  // Convert user to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, email, profilePictureUrl];
}