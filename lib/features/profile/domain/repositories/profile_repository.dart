import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

/// EN: Repository interface for profile data operations
/// KO: 프로필 데이터 작업을 위한 리포지토리 인터페이스
abstract class ProfileRepository {
  /// EN: Get current user profile
  /// KO: 현재 사용자 프로필 가져오기
  Future<Result<UserProfile>> getCurrentProfile();

  /// EN: Update user profile
  /// KO: 사용자 프로필 업데이트
  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  /// EN: Get user's visit history
  /// KO: 사용자의 방문 기록 가져오기
  Future<Result<List<VisitRecord>>> getVisitHistory({
    int page = 0,
    int size = 20,
  });

  /// EN: Get user's favorites
  /// KO: 사용자의 즐겨찾기 가져오기
  Future<Result<UserFavorites>> getFavorites();
}

/// EN: Visit record entity
/// KO: 방문 기록 엔티티
class VisitRecord {
  const VisitRecord({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.visitDate,
    this.photos = const [],
    this.notes,
  });

  final String id;
  final String placeId;
  final String placeName;
  final DateTime visitDate;
  final List<String> photos;
  final String? notes;
}

/// EN: User favorites collection
/// KO: 사용자 즐겨찾기 컬렉션
class UserFavorites {
  const UserFavorites({
    this.places = const [],
    this.events = const [],
  });

  final List<String> places;
  final List<String> events;
}