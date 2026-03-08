# ADR-20260308-community-on-demand-translation-v100

## Status
Accepted

## Date
2026-03-08

## Context
- 백엔드 요청서
  `docs/frontend/community-on-demand-translation-request-20260308.md` 기준으로
  커뮤니티 자동번역 응답 모델을 제거하고 요청형 번역으로 전환해야 했다.
- 요구사항 핵심:
  - 커뮤니티 본문/댓글/피드는 원문 그대로 표시
  - 사용자가 `번역` 버튼 탭할 때만 번역 API 호출
  - `contentId + targetLanguage` 기준 클라이언트 메모리 캐시
  - `translated=false`/에러 상태를 UI에서 분리 표시

## Decision
1. 새 번역 엔드포인트를 클라이언트 계약에 추가한다.
   - `POST /api/v1/community/translations`
2. 피드 도메인에 요청형 번역 모델을 추가한다.
   - DTO: `CommunityTranslationRequestDto`, `CommunityTranslationDto`
   - Domain: `CommunityTranslation`
   - Repository API: `translateCommunityText(...)`
3. UI 상태 관리는 별도 컨트롤러로 분리한다.
   - `CommunityTranslationController`를 추가
   - 상태: `idle/loading/translated/noResult/error`
   - in-flight dedupe 및 메모리 캐시 적용
4. 번역 UI는 재사용 컴포넌트로 통일한다.
   - `CommunityTranslationPanel` 추가
   - 적용 위치:
     - 게시글 상세 본문
     - 댓글/답글/스레드
     - 피드 카드 미리보기(보드/레거시 feed 페이지)
5. 비로그인 상태는 API 호출 대신 안내 스낵바 처리한다.

## Alternatives Considered
1. 각 화면에서 번역 상태를 개별 `StatefulWidget`로 관리
   - 중복 구현이 커지고 동일 콘텐츠 재사용 캐시가 어렵다.
2. 리포지토리 레벨에 영속 캐시 저장
   - 본 릴리즈는 메모리 캐시 요구만 있어 범위를 벗어난다.

## Consequences
### Positive
- 번역 호출이 사용자 액션 기반으로 제한되어 불필요 호출을 줄인다.
- 댓글/답글 포함 다수 화면에서 동일한 번역 UX를 유지할 수 있다.
- `translated=false` 및 오류 케이스를 분리해 UI 안정성이 좋아진다.

### Trade-offs
- 앱 재시작 시 번역 캐시는 초기화된다(메모리 캐시 정책).
- 현재는 sourceLanguage 자동 추정 힌트를 별도 전달하지 않는다.

## Scope
- `lib/core/constants/api_constants.dart`
- `lib/core/constants/api_v3_endpoints_catalog.dart`
- `lib/features/feed/data/dto/community_translation_dto.dart`
- `lib/features/feed/domain/entities/feed_entities.dart`
- `lib/features/feed/domain/repositories/feed_repository.dart`
- `lib/features/feed/data/datasources/feed_remote_data_source.dart`
- `lib/features/feed/data/repositories/feed_repository_impl.dart`
- `lib/features/feed/application/community_translation_controller.dart`
- `lib/features/feed/application/feed_controller.dart`
- `lib/features/feed/presentation/widgets/community_translation_panel.dart`
- `lib/features/feed/presentation/pages/post_detail_page.dart`
- `lib/features/feed/presentation/pages/board_page.dart`
- `lib/features/feed/presentation/pages/feed_page.dart`
- `test/features/feed/data/community_translation_dto_test.dart`
- `test/features/feed/application/community_translation_controller_test.dart`
- `test/core/constants/api_endpoints_contract_test.dart`

## Validation
- `flutter analyze lib/features/feed/application/community_translation_controller.dart lib/features/feed/presentation/widgets/community_translation_panel.dart lib/features/feed/presentation/pages/post_detail_page.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/feed_page.dart lib/features/feed/data/datasources/feed_remote_data_source.dart lib/features/feed/data/repositories/feed_repository_impl.dart lib/features/feed/domain/repositories/feed_repository.dart lib/features/feed/domain/entities/feed_entities.dart lib/features/feed/data/dto/community_translation_dto.dart lib/core/constants/api_constants.dart lib/core/constants/api_v3_endpoints_catalog.dart test/features/feed/data/community_translation_dto_test.dart test/features/feed/application/community_translation_controller_test.dart test/core/constants/api_endpoints_contract_test.dart`
- `flutter test test/features/feed/data/community_translation_dto_test.dart test/features/feed/application/community_translation_controller_test.dart test/core/constants/api_endpoints_contract_test.dart`
