/// EN: Authentication repository interface.
/// KO: 인증 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/oauth_provider.dart';

/// EN: Contract for authentication data operations.
/// KO: 인증 데이터 작업을 위한 계약.
abstract class AuthRepository {
  Future<Result<AuthTokens>> login({
    required String username,
    required String password,
  });

  Future<Result<AuthTokens>> register({
    required String username,
    required String password,
    required String nickname,
  });

  Future<Result<AuthTokens>> refresh();

  Future<Result<void>> logout();

  /// EN: Exchange OAuth authorization code for tokens.
  /// KO: OAuth 인가 코드를 토큰으로 교환.
  Future<Result<AuthTokens>> exchangeOAuthCode({
    required OAuthProvider provider,
    required String code,
    String? state,
  });
}
