import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';

/// EN: Use case for user logout functionality
/// KO: 사용자 로그아웃 기능을 위한 유스케이스
class LogoutUseCase {
  /// EN: Creates logout use case with auth repository dependency
  /// KO: 인증 리포지터리 의존성을 가진 로그아웃 유스케이스 생성
  const LogoutUseCase({
    required this.authRepository,
  });

  /// EN: Authentication repository for logout operations
  /// KO: 로그아웃 작업을 위한 인증 리포지터리
  final AuthRepository authRepository;

  /// EN: Execute logout operation
  /// KO: 로그아웃 작업 실행
  Future<Result<void>> call() async {
    // EN: Perform logout through repository
    // KO: 리포지터리를 통한 로그아웃 수행
    final logoutResult = await authRepository.logout();
    
    // EN: Clear stored tokens regardless of logout API result
    // KO: 로그아웃 API 결과에 관계없이 저장된 토큰 지우기
    final clearResult = await authRepository.clearTokens();
    
    // EN: Return logout result, but ensure tokens are cleared
    // KO: 로그아웃 결과 반환하되 토큰이 지워지도록 보장
    return logoutResult.flatMap((_) => clearResult);
  }
}