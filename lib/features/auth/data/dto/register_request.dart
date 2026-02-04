/// EN: Register request DTO.
/// KO: 회원가입 요청 DTO.
library;

/// EN: DTO for registration request payload.
/// KO: 회원가입 요청 페이로드 DTO.
class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.password,
    required this.nickname,
  });

  final String username;
  final String password;
  final String nickname;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
    };
  }
}
