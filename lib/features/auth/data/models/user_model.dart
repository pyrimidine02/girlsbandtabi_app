import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// EN: Data transfer object for User entity with JSON serialization
/// KO: JSON 직렬화를 지원하는 User 엔티티의 데이터 전송 객체
@freezed
class UserModel with _$UserModel {
  /// EN: Creates a UserModel instance
  /// KO: UserModel 인스턴스 생성
  const factory UserModel({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
    @Default(false) bool isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  /// EN: Creates UserModel from JSON data
  /// KO: JSON 데이터에서 UserModel 생성
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// EN: Creates UserModel from domain entity
  /// KO: 도메인 엔티티에서 UserModel 생성
  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );
}

/// EN: Extension to convert UserModel to domain entity
/// KO: UserModel을 도메인 엔티티로 변환하는 확장
extension UserModelX on UserModel {
  /// EN: Convert to domain User entity
  /// KO: 도메인 User 엔티티로 변환
  User toEntity() => User(
        id: id,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
        isEmailVerified: isEmailVerified,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// EN: Data transfer object for authentication requests
/// KO: 인증 요청을 위한 데이터 전송 객체
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String username,
    required String password,
  }) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);
}

@freezed
class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    required String username,
    required String password,
    required String nickname,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);
}

/// EN: Data transfer object for authentication response
/// KO: 인증 응답을 위한 데이터 전송 객체
@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
    UserModel? user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

/// EN: Extension to convert AuthResponseModel to domain entities
/// KO: AuthResponseModel을 도메인 엔티티로 변환하는 확장
extension AuthResponseModelX on AuthResponseModel {
  /// EN: Convert to domain AuthTokens entity
  /// KO: 도메인 AuthTokens 엔티티로 변환
  AuthTokens toTokens() => AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
      );
}
