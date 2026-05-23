class AuthFormModel {
  const AuthFormModel({
    required this.role,
    required this.email,
    required this.password,
    this.name = '',
    this.nickname = '',
  });

  final String role;
  final String email;
  final String password;
  final String name;
  final String nickname;
}
