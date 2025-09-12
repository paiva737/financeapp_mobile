class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> j) =>
      AuthTokens(accessToken: j['accessToken'], refreshToken: j['refreshToken']);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}

class UserMe {
  final String id;
  final String email;
  final String? name;

  UserMe({required this.id, required this.email, this.name});

  factory UserMe.fromJson(Map<String, dynamic> j) =>
      UserMe(id: j['id'].toString(), email: j['email'], name: j['name']);
}
