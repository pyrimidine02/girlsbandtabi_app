/// EN: KT UXD design system spacing constants for Flutter applications
/// KO: Flutter 애플리케이션용 KT UXD 디자인 시스템 간격 상수

/// EN: Based on 8px grid system following KT UXD design principles
/// KO: KT UXD 디자인 원칙을 따르는 8px 그리드 시스템 기반
class KTSpacing {
  // EN: Base spacing unit - all other spacing derives from this
  // KO: 기본 간격 단위 - 다른 모든 간격은 이것에서 파생됨
  static const double _baseUnit = 8.0;
  
  // EN: Micro spacing for fine adjustments
  // KO: 세밀한 조정을 위한 마이크로 간격
  static const double xxs = _baseUnit * 0.5; // 4px
  static const double xxsmall = xxs;
  
  // EN: Extra small spacing for tight layouts
  // KO: 타이트한 레이아웃을 위한 매우 작은 간격
  static const double xs = _baseUnit; // 8px
  static const double xsmall = xs;
  
  // EN: Small spacing for component internal padding
  // KO: 컴포넌트 내부 패딩을 위한 작은 간격
  static const double sm = _baseUnit * 1.5; // 12px
  static const double small = sm;
  
  // EN: Medium spacing - most commonly used spacing
  // KO: 중간 간격 - 가장 많이 사용되는 간격
  static const double md = _baseUnit * 2; // 16px
  static const double medium = md;
  
  // EN: Large spacing for section separation
  // KO: 섹션 분리를 위한 큰 간격
  static const double lg = _baseUnit * 3; // 24px
  static const double large = lg;
  
  // EN: Extra large spacing for major layout sections
  // KO: 주요 레이아웃 섹션을 위한 매우 큰 간격
  static const double xl = _baseUnit * 4; // 32px
  static const double xlarge = xl;
  
  // EN: Extra extra large spacing for page-level separation
  // KO: 페이지 레벨 분리를 위한 매우 매우 큰 간격
  static const double xxl = _baseUnit * 6; // 48px
  static const double xxlarge = xxl;

  /// EN: Triple extra large spacing for hero sections
  /// KO: 히어로 섹션을 위한 초대형 간격
  static const double xxxlarge = _baseUnit * 8; // 64px
  
  // EN: Specialized spacing constants for specific use cases
  // KO: 특정 사용 사례를 위한 전문 간격 상수
  
  /// EN: Standard padding for cards and containers
  /// KO: 카드와 컨테이너를 위한 표준 패딩
  static const double cardPadding = 20.0;
  
  /// EN: Horizontal padding for page content
  /// KO: 페이지 콘텐츠를 위한 수평 패딩
  static const double pageHorizontal = 20.0;
  
  /// EN: Vertical padding for page content
  /// KO: 페이지 콘텐츠를 위한 수직 패딩
  static const double pageVertical = 24.0;
  
  /// EN: Safe area padding for screen edges
  /// KO: 화면 가장자리를 위한 안전 영역 패딩
  static const double safeArea = 16.0;
  
  /// EN: Minimum touch target size for accessibility
  /// KO: 접근성을 위한 최소 터치 대상 크기
  static const double touchTarget = 44.0;
  
  /// EN: Spacing between list items
  /// KO: 목록 항목 간 간격
  static const double listItemGap = 12.0;
  
  /// EN: Spacing between form fields
  /// KO: 폼 필드 간 간격
  static const double formFieldGap = 16.0;
  
  /// EN: Spacing for button groups
  /// KO: 버튼 그룹을 위한 간격
  static const double buttonGap = 12.0;
  
  /// EN: Spacing between sections in a page
  /// KO: 페이지 내 섹션 간 간격
  static const double sectionGap = 32.0;
  
  /// EN: Spacing for navigation elements
  /// KO: 네비게이션 요소를 위한 간격
  static const double navigationPadding = 16.0;
  
  /// EN: Spacing for modal and dialog padding
  /// KO: 모달과 다이얼로그 패딩을 위한 간격
  static const double modalPadding = 24.0;
  
  /// EN: Spacing for tab bar and app bar content
  /// KO: 탭 바와 앱 바 콘텐츠를 위한 간격
  static const double appBarPadding = 16.0;
  
  /// EN: Spacing for floating action button positioning
  /// KO: 플로팅 액션 버튼 위치를 위한 간격
  static const double fabMargin = 16.0;
  
  /// EN: Spacing for snackbar and notification margins
  /// KO: 스낵바와 알림 여백을 위한 간격
  static const double notificationMargin = 16.0;
  
  // EN: Border radius constants following KT UXD design
  // KO: KT UXD 디자인을 따르는 테두리 반지름 상수
  
  /// EN: Small border radius for input fields and small components
  /// KO: 입력 필드와 작은 컴포넌트를 위한 작은 테두리 반지름
  static const double borderRadiusSmall = 8.0;
  
  /// EN: Medium border radius for cards and containers
  /// KO: 카드와 컨테이너를 위한 중간 테두리 반지름
  static const double borderRadiusMedium = 12.0;
  
  /// EN: Large border radius for modals and major UI elements
  /// KO: 모달과 주요 UI 요소를 위한 큰 테두리 반지름
  static const double borderRadiusLarge = 16.0;
  
  /// EN: Extra large border radius for decorative elements
  /// KO: 장식 요소를 위한 매우 큰 테두리 반지름
  static const double borderRadiusXLarge = 24.0;
  
  /// EN: Circular border radius for profile images and icons
  /// KO: 프로필 이미지와 아이콘을 위한 원형 테두리 반지름
  static const double borderRadiusCircular = 999.0;
  
  // EN: Elevation values for Material Design depth
  // KO: Material Design 깊이를 위한 엘리베이션 값
  
  /// EN: No elevation for flat components
  /// KO: 플랫 컴포넌트를 위한 엘리베이션 없음
  static const double elevationNone = 0.0;
  
  /// EN: Subtle elevation for cards
  /// KO: 카드를 위한 미묘한 엘리베이션
  static const double elevationSubtle = 1.0;
  
  /// EN: Low elevation for interactive elements
  /// KO: 인터랙티브 요소를 위한 낮은 엘리베이션
  static const double elevationLow = 2.0;
  
  /// EN: Medium elevation for floating elements
  /// KO: 플로팅 요소를 위한 중간 엘리베이션
  static const double elevationMedium = 4.0;
  
  /// EN: High elevation for modals and dialogs
  /// KO: 모달과 다이얼로그를 위한 높은 엘리베이션
  static const double elevationHigh = 8.0;
  
  /// EN: Maximum elevation for top-level overlays
  /// KO: 최상위 오버레이를 위한 최대 엘리베이션
  static const double elevationMax = 16.0;
  
  // EN: Utility methods for responsive spacing
  // KO: 반응형 간격을 위한 유틸리티 메서드
  
  /// EN: Calculate spacing based on screen width factor
  /// KO: 화면 너비 인수를 기반으로 간격 계산
  static double responsive(double baseSpacing, double screenWidth) {
    // EN: Adjust spacing for different screen sizes
    // KO: 다양한 화면 크기에 맞게 간격 조정
    if (screenWidth < 600) {
      return baseSpacing; // Mobile
    } else if (screenWidth < 1200) {
      return baseSpacing * 1.2; // Tablet
    } else {
      return baseSpacing * 1.5; // Desktop
    }
  }
  
  /// EN: Get spacing value by multiplying base unit
  /// KO: 기본 단위에 곱하여 간격 값 가져오기
  static double multiple(double multiplier) {
    return _baseUnit * multiplier;
  }
  
  /// EN: Validate spacing value against design system grid
  /// KO: 디자인 시스템 그리드에 대해 간격 값 검증
  static bool isValidSpacing(double value) {
    return value % (_baseUnit / 2) == 0; // Must be multiple of 4px
  }
  
  /// EN: Round spacing value to nearest valid grid value
  /// KO: 간격 값을 가장 가까운 유효한 그리드 값으로 반올림
  static double roundToGrid(double value) {
    final double halfUnit = _baseUnit / 2; // 4px
    return (value / halfUnit).round() * halfUnit;
  }
}
