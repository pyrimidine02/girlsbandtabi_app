import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// EN: Use case for getting current authenticated user
/// KO: 현재 인증된 사용자를 가져오는 유스케이스
class GetCurrentUserUseCase {
  /// EN: Creates get current user use case with auth repository dependency
  /// KO: 인증 리포지터리 의존성을 가진 현재 사용자 가져오기 유스케이스 생성
  const GetCurrentUserUseCase({
    required this.authRepository,
  });

  /// EN: Authentication repository for user operations
  /// KO: 사용자 작업을 위한 인증 리포지터리
  final AuthRepository authRepository;

  /// EN: Execute get current user operation
  /// KO: 현재 사용자 가져오기 작업 실행
  Future<Result<User>> call() async {
    // EN: Check if user is authenticated first
    // KO: 먼저 사용자가 인증되었는지 확인
    final authResult = await authRepository.isAuthenticated();
    
    return authResult.flatMapAsync((isAuth) async {
      if (!isAuth) {
        return const ResultFailure(AuthFailure(
          message: 'User is not authenticated',
          code: 'NOT_AUTHENTICATED',
        ));
      }

      // EN: Get current user if authenticated
      // KO: 인증된 경우 현재 사용자 가져오기
      return authRepository.getCurrentUser();
    });
  }
}
