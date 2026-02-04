# ADR-20251128: KT UXD v1.1 Layout Pattern System Implementation

## Status
**Accepted** - Implementation completed on 2025-11-28

## Context

Girls Band Tabi 앱의 사용자 경험을 개선하기 위해 일관된 레이아웃 패턴과 네비게이션 시스템이 필요했습니다. 기존 앱은 개별 화면마다 다른 레이아웃 접근 방식을 사용하고 있어 다음과 같은 문제점들이 있었습니다:

### Problems Identified
1. **일관성 부족**: 화면별로 다른 레이아웃 구조와 스타일링
2. **반응형 디자인 미흡**: 모바일, 태블릿, 데스크톱 화면 크기에 대한 체계적인 대응 부족
3. **네비게이션 혼재**: 하단 네비게이션과 다른 네비게이션 패턴이 혼용되어 사용자 혼란 야기
4. **접근성 미준수**: WCAG 가이드라인에 따른 접근성 기능 부족
5. **유지보수성 저하**: 반복되는 레이아웃 코드와 하드코딩된 스타일링

### Business Requirements
- Girls Band Tabi 앱의 핵심 기능(홈, 순례, 라이브, 즐겨찾기, 프로필)에 최적화된 네비게이션
- 음악, 라이브 이벤트, 순례지 탐방 콘텐츠에 특화된 레이아웃 패턴
- 다양한 디바이스에서 일관된 사용자 경험 제공
- KT 브랜드 아이덴티티 반영 및 UXD v1.1 사양 준수

## Decision

KT UXD v1.1 사양에 따른 포괄적인 레이아웃 패턴 시스템을 구현하기로 결정했습니다.

### Core Layout Components

#### 1. KTAppLayout - 메인 앱 레이아웃
```dart
class KTAppLayout extends StatelessWidget {
  // 반응형 구조, Safe Area 처리, 키보드 대응
  // 시스템 UI 오버레이 통합 (상태바, 네비게이션 바)
  // 앱바, 바디, 하단 네비게이션 영역 관리
}
```

#### 2. KTPageLayout - 표준 페이지 레이아웃
```dart
class KTPageLayout extends StatelessWidget {
  // 헤더, 컨텐츠, 푸터 영역 구조화
  // 스크롤 처리 및 Pull-to-refresh 지원
  // 로딩 상태 오버레이와 KT 브랜드 그래디언트 옵션
  // 뒤로가기 버튼과 액션 버튼 표준화
}
```

#### 3. KTGridLayout - 12컬럼 그리드 시스템
```dart
class KTGridLayout extends StatelessWidget {
  // 반응형 브레이크포인트: 320px(모바일) ~ 1440px+(데스크톱)
  // 자동 컬럼 수 조정: 모바일 1-2개, 태블릿 3-4개, 데스크톱 5-6개
  // KT 간격 가이드라인에 따른 거터와 마진 계산
}
```

#### 4. KTBottomNavigation - 하단 네비게이션
```dart
class KTBottomNavigation extends StatelessWidget {
  // Girls Band Tabi 전용 5개 탭: 홈, 순례, 라이브, 즐겨찾기, 프로필
  // 뱃지 표시 기능 (라이브 이벤트 알림 등)
  // KT 브랜드 색상과 애니메이션 적용
  // WCAG AA 준수 터치 타겟 (48px 최소 크기)
}
```

#### 5. KTSideNavigation - 사이드 네비게이션
```dart
class KTSideNavigation extends StatelessWidget {
  // 태블릿/데스크톱용 확장/축소 가능한 사이드바
  // 계층형 메뉴 구조와 사용자 프로필 영역
  // Girls Band Tabi 로고 및 브랜딩 통합
  // 키보드 네비게이션 완전 지원
}
```

#### 6. KTTabLayout - 탭 레이아웃
```dart
class KTTabLayout extends StatefulWidget {
  // 상단/하단 탭 위치 지원
  // 스크롤 가능한 탭과 고정 탭 구성
  // KT 브랜드 인디케이터 애니메이션
  // 동적 탭 추가/제거 기능
}
```

### Responsive Design Strategy

#### Breakpoint System
```dart
class KTBreakpoints {
  static const double xs = 320.0;    // Mobile Small
  static const double sm = 576.0;    // Mobile
  static const double md = 768.0;    // Tablet
  static const double lg = 1024.0;   // Desktop Small
  static const double xl = 1200.0;   // Desktop
  static const double xxl = 1440.0;  // Desktop Large
}
```

#### Navigation Adaptation
- **Mobile (< 768px)**: KTBottomNavigation 사용
- **Tablet (768px - 1024px)**: Drawer + KTSideNavigation 사용  
- **Desktop (> 1024px)**: 고정 KTSideNavigation Rail 사용

#### Utility Classes
```dart
class KTLayoutUtils {
  // 화면 크기 감지: isMobile(), isTablet(), isDesktop()
  // 반응형 값 선택: responsive<T>(mobile, tablet, desktop)
  // 네비게이션 타입 자동 결정: getNavigationType()
}
```

### Design Token Integration

모든 레이아웃 컴포넌트는 기존 KT 디자인 토큰을 활용:

- **Colors**: `KTColors` - 브랜드 색상, 의미론적 색상, 다크 테마 지원
- **Spacing**: `KTSpacing` - 8px 그리드 시스템, 반응형 간격 계산
- **Typography**: `KTTypography` - Pretendard/Nunito Sans 폰트, 다국어 지원  
- **Animations**: `KTAnimations` - KT 브랜드 애니메이션 곡선과 시간

### Accessibility Implementation

WCAG 2.1 AA 레벨 준수를 위한 기능들:

- **키보드 네비게이션**: 모든 인터랙티브 요소 접근 가능
- **스크린 리더 지원**: 적절한 semantic labels와 hints 제공
- **터치 타겟**: 최소 48px 크기 보장
- **색상 대비**: KTColors의 자동 접근성 검증 시스템 활용
- **포커스 관리**: 명확한 포커스 인디케이터와 논리적 탭 순서

## Implementation Details

### File Structure
```
lib/widgets/common/
├── kt_layouts.dart              # 메인 레이아웃 컴포넌트들
├── kt_layouts_example.dart      # 사용 예제와 데모
test/widgets/
└── kt_layouts_test.dart         # 포괄적인 테스트 스위트
```

### Integration Points

#### Router Integration
기존 GoRouter와 StatefulShellRoute 구조 유지하면서 레이아웃 컴포넌트 통합:

```dart
// 기존 main_screen.dart 업데이트 필요
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return KTAppLayout(
      body: _buildResponsiveLayout(navigationShell),
      bottomNavigationBar: _buildResponsiveNavigation(),
    );
  },
  // ... 기존 branches 유지
)
```

#### State Management Integration
Riverpod provider와의 원활한 연동:

```dart
// 네비게이션 상태 관리
final navigationIndexProvider = StateProvider<int>((ref) => 0);
final layoutTypeProvider = Provider<KTNavigationType>((ref) {
  // MediaQuery context 기반 자동 결정
});
```

### Girls Band Tabi Customizations

앱 특성에 맞는 커스터마이제이션:

1. **음악 중심 아이콘**: 네비게이션에 음표, 이벤트, 장소 아이콘 사용
2. **한국어 우선**: 네비게이션 라벨을 한국어로 표시 (홈, 순례, 라이브, 즐겨찾기, 프로필)
3. **라이브 이벤트 특화**: 라이브 탭에 실시간 알림 배지 표시
4. **순례지 맵 통합**: 순례 섹션에서 지도/리스트 뷰 전환 지원
5. **사용자 프로필**: 음악 취향과 방문 기록을 포함한 프로필 영역

## Consequences

### Positive Impacts

1. **일관성 향상**: 모든 화면에서 동일한 레이아웃 패턴 사용
2. **개발 효율성**: 재사용 가능한 레이아웃 컴포넌트로 개발 시간 단축
3. **사용자 경험**: 예측 가능하고 직관적인 네비게이션
4. **반응형 지원**: 모든 디바이스에서 최적화된 경험
5. **접근성**: WCAG 준수로 더 많은 사용자에게 접근 가능
6. **유지보수성**: 중앙화된 레이아웃 로직으로 변경사항 관리 용이

### Implementation Requirements

1. **기존 화면 마이그레이션**: 모든 화면을 새 레이아웃 시스템으로 점진적 이전
2. **테스트 확장**: 기존 화면 테스트에 레이아웃 컴포넌트 테스트 추가
3. **문서화**: 개발팀을 위한 레이아웃 사용 가이드 작성
4. **성능 모니터링**: 레이아웃 변경이 앱 성능에 미치는 영향 추적

### Migration Strategy

#### Phase 1: Foundation (완료)
- [x] 레이아웃 컴포넌트 구현
- [x] 테스트 스위트 작성
- [x] 예제 및 문서화

#### Phase 2: Integration (다음 단계)
- [ ] MainScreen을 KTAppLayout으로 마이그레이션
- [ ] 홈 화면을 KTPageLayout으로 전환
- [ ] 순례 화면에 KTTabLayout 적용
- [ ] 라이브 이벤트 화면에 KTGridLayout 적용

#### Phase 3: Optimization (후속)
- [ ] 성능 최적화 및 미세 조정
- [ ] 사용자 피드백 반영
- [ ] 고급 레이아웃 기능 추가 (필요시)

### Testing Strategy

포괄적인 테스트 커버리지:

- **Unit Tests**: 각 레이아웃 컴포넌트의 기본 기능
- **Widget Tests**: UI 상호작용 및 상태 변화
- **Integration Tests**: 전체 네비게이션 플로우
- **Responsive Tests**: 다양한 화면 크기에서의 동작
- **Accessibility Tests**: 접근성 기능 검증

### Performance Considerations

- **메모리 효율성**: StatelessWidget 우선 사용으로 불필요한 rebuild 최소화
- **렌더링 최적화**: RepaintBoundary와 const 위젯 적극 활용
- **애니메이션 성능**: KT 브랜드 애니메이션 곡선 사용으로 부드러운 전환
- **번들 크기**: 트리 셰이킹으로 사용하지 않는 컴포넌트 제거

## References

- [KT UXD v1.1 Design Specification](../KT_UXD_Design_System_Analysis.md)
- [Material Design 3 Layout Guidelines](https://m3.material.io/foundations/layout)
- [WCAG 2.1 Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/)
- [Flutter Layout Documentation](https://docs.flutter.dev/development/ui/layout)
- [Girls Band Tabi App Architecture](../architecture.md)

## Change History

- **2025-11-28**: 초기 ADR 작성 및 레이아웃 시스템 구현 완료
- **향후**: 마이그레이션 진행에 따른 업데이트 예정