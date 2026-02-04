/// EN: Remote data source for authentication.
/// KO: 인증용 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/oauth_provider.dart';
import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../dto/refresh_token_request.dart';
import '../dto/token_response.dart';

/// EN: Handles authentication API requests.
/// KO: 인증 API 요청을 처리합니다.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<TokenResponse>> login(LoginRequest request) {
    return _apiClient.post<TokenResponse>(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<TokenResponse>> register(RegisterRequest request) {
    return _apiClient.post<TokenResponse>(
      ApiEndpoints.register,
      data: request.toJson(),
      fromJson: (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<TokenResponse>> refresh(RefreshTokenRequest request) {
    return _apiClient.post<TokenResponse>(
      ApiEndpoints.refresh,
      data: request.toJson(),
      fromJson: (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<void>> logout(RefreshTokenRequest? request) {
    return _apiClient.post<void>(ApiEndpoints.logout, data: request?.toJson());
  }

  /// EN: Exchange OAuth authorization code for tokens.
  /// KO: OAuth 인가 코드를 토큰으로 교환합니다.
  Future<Result<TokenResponse>> exchangeOAuthCode({
    required OAuthProvider provider,
    required String code,
    String? state,
  }) {
    return _apiClient.get<TokenResponse>(
      ApiEndpoints.oauthCallback(provider.id),
      queryParameters: {'code': code, if (state != null) 'state': state},
      fromJson: (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
