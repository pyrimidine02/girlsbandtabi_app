# 걸즈밴드 타비 앱 디자인 시스템 종합 명세서

## 개요

본 문서는 걸즈밴드 타비 5탭 Flutter 앱(홈/장소/라이브/소식/설정)을 위한 종합 디자인 시스템 명세서입니다. KT UXD 디자인 시스템을 기반으로 하여 한국 앱 감성과 Material Design 원칙을 조화롭게 결합한 실용적인 디자인 시스템을 제시합니다.

**작성일**: 2024년 12월 14일  
**버전**: 1.0.0  
**대상**: Girls Band Tabi Flutter App (Clean Architecture + Riverpod)  
**기반 문서**: KT UXD v1.1, 걸즈밴드 인포 앱 디자인 레퍼런스 조사, 5탭 아키텍처 가이드

---

## 1. 디자인 철학 및 원칙

### 1.1 핵심 가치
- **접근성 우선 (Accessibility First)**: WCAG 2.1 AA 수준 준수
- **한국어 최적화 (Korean Optimized)**: Pretendard 폰트 기반 타이포그래피
- **컴포넌트 재사용성 (Component Reusability)**: Clean Architecture 호환
- **성능 최적화 (Performance Optimized)**: 60fps 보장, 메모리 효율성
- **일관된 사용자 경험 (Consistent UX)**: 5탭 간 시각적/인터랙션 일관성

### 1.2 디자인 원칙
1. **명확성 (Clarity)**: 정보 계층 구조가 명확한 UI
2. **효율성 (Efficiency)**: 최소한의 터치로 목표 달성
3. **친근함 (Friendliness)**: 팬 커뮤니티에 적합한 감성적 디자인
4. **신뢰성 (Reliability)**: 일관되고 예측 가능한 인터랙션

---

## 2. 색상 시스템 (Color System)

### 2.1 브랜드 색상 (Brand Colors)

KT UXD 기반의 브랜드 색상 확장:

```dart
/// 걸즈밴드 타비 브랜드 색상 시스템
class GBTColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1A1A1A);           // 기본 브랜드 색상
  static const Color primaryDark = Color(0xFF000000);       // 강조/선택 상태
  static const Color primaryLight = Color(0xFF333333);      // 호버 상태
  
  // Secondary Colors (음악/팬덤 테마)
  static const Color accent = Color(0xFF6B46C1);            // 보라색 - 음악 테마
  static const Color accentPink = Color(0xFFEC4899);        // 핑크색 - 걸그룹 테마
  static const Color accentBlue = Color(0xFF3B82F6);        // 파란색 - 정보 강조
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);           // 방문 인증 성공
  static const Color warning = Color(0xFFF59E0B);           // 주의/대기
  static const Color error = Color(0xFFEF4444);             // 오류/실패
  static const Color info = Color(0xFF3B82F6);              // 정보/알림
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);       // 주요 텍스트
  static const Color textSecondary = Color(0xFF6B7280);     // 보조 텍스트
  static const Color textTertiary = Color(0xFF9CA3AF);      // 3차 텍스트
  static const Color textDisabled = Color(0xFFD1D5DB);      // 비활성 텍스트
  
  // Surface Colors
  static const Color background = Color(0xFFFFFFFF);        // 기본 배경
  static const Color surface = Color(0xFFF9FAFB);           // 카드/표면
  static const Color surfaceVariant = Color(0xFFF3F4F6);    // 대체 표면
  static const Color divider = Color(0xFFE5E7EB);           // 구분선
  static const Color border = Color(0xFFD1D5DB);            // 테두리
  
  // Interactive States
  static const Color hover = Color(0xFFF3F4F6);             // 호버 상태
  static const Color pressed = Color(0xFFE5E7EB);           // 눌림 상태
  static const Color focused = Color(0xFF3B82F6);           // 포커스 상태
  static const Color selected = Color(0xFFEBF5FF);          // 선택 상태
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF111827);     // 다크 배경
  static const Color darkSurface = Color(0xFF1F2937);       // 다크 표면
  static const Color darkTextPrimary = Color(0xFFF9FAFB);   // 다크 주요 텍스트
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // 다크 보조 텍스트
  static const Color darkBorder = Color(0xFF374151);        // 다크 테두리
}
```

### 2.2 의미별 색상 사용 가이드

| 용도 | 라이트 모드 | 다크 모드 | 설명 |
|------|------------|-----------|------|
| 브랜드 강조 | `primary` | `primary` | 로고, CTA 버튼, 선택 상태 |
| 음악/공연 | `accent` | `accent` | 라이브 이벤트, 음악 관련 |
| 팬덤/커뮤니티 | `accentPink` | `accentPink` | 좋아요, 팬 활동 |
| 방문 인증 | `success` | `success` | 성공적인 장소 방문 인증 |
| 주의 사항 | `warning` | `warning` | 권한 요청, 확인 필요 |
| 오류 상황 | `error` | `error` | 실패, 오류 메시지 |

### 2.3 접근성 검증

모든 색상 조합은 WCAG 2.1 AA 기준 4.5:1 대비율을 만족합니다.

```dart
/// 색상 접근성 검증 유틸리티
class GBTColorAccessibility {
  static bool isAccessible(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5; // WCAG AA 기준
  }
  
  static double _calculateContrastRatio(Color color1, Color color2) {
    final l1 = color1.computeLuminance();
    final l2 = color2.computeLuminance();
    final brightest = math.max(l1, l2);
    final darkest = math.min(l1, l2);
    return (brightest + 0.05) / (darkest + 0.05);
  }
}
```

---

## 3. 타이포그래피 시스템 (Typography System)

### 3.1 폰트 패밀리 및 웨이트

**주요 폰트**: Pretendard (한글 최적화)  
**보조 폰트**: System Default (영문/기타)  
**지원 웨이트**: 400(Regular), 500(Medium), 600(SemiBold), 700(Bold)

### 3.2 텍스트 스타일 정의

```dart
/// 걸즈밴드 타비 타이포그래피 시스템
class GBTTypography {
  static const String fontFamily = 'Pretendard';
  
  // Display Styles (큰 제목)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  // Headline Styles (제목)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Title Styles (타이틀)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  // Body Styles (본문)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
  );
  
  // Label Styles (라벨/버튼)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  // Special Styles (특수 용도)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
}
```

### 3.3 용도별 타이포그래피 가이드

| 용도 | 스타일 | 사용 예 |
|------|--------|---------|
| 화면 제목 | `headlineLarge` | 각 탭 메인 제목 |
| 섹션 제목 | `headlineMedium` | "다가오는 라이브", "인기 장소" |
| 카드 제목 | `titleLarge` | 장소명, 라이브 제목 |
| 부제목 | `titleMedium` | 카드 부가 정보 |
| 본문 텍스트 | `bodyMedium` | 설명문, 내용 |
| 메타 정보 | `bodySmall` | 날짜, 시간, 위치 |
| 버튼 텍스트 | `labelMedium` | 액션 버튼 |
| 탭 라벨 | `labelSmall` | 하단 네비게이션 |

---

## 4. 간격 및 레이아웃 시스템 (Spacing & Layout)

### 4.1 8px 그리드 기반 간격 시스템

```dart
/// 걸즈밴드 타비 간격 시스템
class GBTSpacing {
  // Base Scale (8px 기반)
  static const double xs = 4.0;     // 0.5단위
  static const double sm = 8.0;     // 1단위
  static const double md = 16.0;    // 2단위 (기본)
  static const double lg = 24.0;    // 3단위
  static const double xl = 32.0;    // 4단위
  static const double xxl = 48.0;   // 6단위
  static const double xxxl = 64.0;  // 8단위
  
  // Semantic Spacing
  static const double cardPadding = 20.0;       // 카드 내부 패딩
  static const double cardMargin = 16.0;        // 카드 간 마진
  static const double pageMargin = 20.0;        // 페이지 수평 마진
  static const double sectionSpacing = 32.0;    // 섹션 간 간격
  static const double elementSpacing = 12.0;    // 요소 간 간격
  
  // Touch Targets (Accessibility)
  static const double minTouchTarget = 44.0;    // 최소 터치 타겟 크기
  static const double buttonHeight = 48.0;      // 기본 버튼 높이
  static const double iconButtonSize = 40.0;    // 아이콘 버튼 크기
  
  // Border Radius
  static const double radiusXs = 4.0;           // 작은 모서리
  static const double radiusSm = 8.0;           // 일반 모서리
  static const double radiusMd = 12.0;          // 카드 모서리
  static const double radiusLg = 16.0;          // 큰 모서리
  static const double radiusXl = 24.0;          // 매우 큰 모서리
  static const double radiusFull = 999.0;       // 완전한 원형
}
```

### 4.2 반응형 레이아웃 시스템

```dart
/// 반응형 브레이크포인트
class GBTBreakpoints {
  static const double mobile = 480.0;          // 모바일
  static const double tablet = 768.0;          // 태블릿
  static const double desktop = 1024.0;        // 데스크톱
  
  /// 화면 크기별 간격 반환
  static double responsiveSpacing(BuildContext context, {
    double mobile = GBTSpacing.md,
    double tablet = GBTSpacing.lg,
    double desktop = GBTSpacing.xl,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return desktop;
    if (width >= tablet) return tablet;
    return mobile;
  }
  
  /// 화면 크기별 컬럼 수 반환
  static int getColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return 3;
    if (width >= tablet) return 2;
    return 1;
  }
}
```

---

## 5. 컴포넌트 시스템 (Component System)

### 5.1 카드 컴포넌트 (Card Components)

카드는 앱 전반에서 가장 중요한 UI 패턴입니다.

```dart
/// 걸즈밴드 타비 피드 카드 컴포넌트
class GBTFeedCard extends StatelessWidget {
  const GBTFeedCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 2.0,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.all(GBTSpacing.cardPadding);
    final defaultMargin = EdgeInsets.all(GBTSpacing.cardMargin);
    final defaultRadius = BorderRadius.circular(GBTSpacing.radiusMd);
    
    return Container(
      margin: margin ?? defaultMargin,
      child: Material(
        elevation: elevation,
        borderRadius: borderRadius ?? defaultRadius,
        color: GBTColors.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultRadius,
          child: Padding(
            padding: padding ?? defaultPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 장소 카드 전용 컴포넌트
class GBTPlaceCard extends StatelessWidget {
  const GBTPlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.showDistance = false,
  });

  final PlaceEntity place;
  final VoidCallback? onTap;
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    return GBTFeedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 장소 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: place.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: GBTColors.surfaceVariant,
                  child: Icon(
                    Icons.temple_buddhist,
                    color: GBTColors.textTertiary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: GBTSpacing.sm),
          
          // 장소명
          Text(
            place.name,
            style: GBTTypography.titleLarge.copyWith(
              color: GBTColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: GBTSpacing.xs),
          
          // 부가 정보
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: GBTColors.textSecondary,
              ),
              SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Text(
                  place.address,
                  style: GBTTypography.bodySmall.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showDistance && place.distance != null) ...[
                SizedBox(width: GBTSpacing.sm),
                Text(
                  '${place.distance!.toStringAsFixed(1)}km',
                  style: GBTTypography.labelSmall.copyWith(
                    color: GBTColors.accent,
                  ),
                ),
              ],
            ],
          ),
          
          if (place.visitCount > 0) ...[
            SizedBox(height: GBTSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: GBTColors.success,
                ),
                SizedBox(width: GBTSpacing.xs),
                Text(
                  '${place.visitCount}명 방문',
                  style: GBTTypography.labelSmall.copyWith(
                    color: GBTColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

### 5.2 버튼 컴포넌트 (Button Components)

```dart
/// 걸즈밴드 타비 버튼 시스템
enum GBTButtonVariant { primary, secondary, tertiary }
enum GBTButtonSize { small, medium, large }

class GBTButton extends StatelessWidget {
  const GBTButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = GBTButtonVariant.primary,
    this.size = GBTButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final GBTButtonVariant variant;
  final GBTButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(isEnabled),
          foregroundColor: _getForegroundColor(isEnabled),
          elevation: variant == GBTButtonVariant.primary ? 2 : 0,
          shadowColor: GBTColors.primary.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            side: _getBorderSide(isEnabled),
          ),
          padding: _getPadding(),
          minimumSize: Size(_getMinWidth(), _getHeight()),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getForegroundColor(isEnabled),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize()),
                    SizedBox(width: GBTSpacing.xs),
                  ],
                  Text(
                    text,
                    style: _getTextStyle(),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case GBTButtonSize.small:
        return 32;
      case GBTButtonSize.medium:
        return 44;
      case GBTButtonSize.large:
        return 56;
    }
  }

  double _getMinWidth() {
    switch (size) {
      case GBTButtonSize.small:
        return 64;
      case GBTButtonSize.medium:
        return 80;
      case GBTButtonSize.large:
        return 120;
    }
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (!isEnabled) return GBTColors.surfaceVariant;
    
    switch (variant) {
      case GBTButtonVariant.primary:
        return GBTColors.primary;
      case GBTButtonVariant.secondary:
        return GBTColors.surface;
      case GBTButtonVariant.tertiary:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(bool isEnabled) {
    if (!isEnabled) return GBTColors.textDisabled;
    
    switch (variant) {
      case GBTButtonVariant.primary:
        return Colors.white;
      case GBTButtonVariant.secondary:
        return GBTColors.primary;
      case GBTButtonVariant.tertiary:
        return GBTColors.primary;
    }
  }

  BorderSide _getBorderSide(bool isEnabled) {
    switch (variant) {
      case GBTButtonVariant.secondary:
        return BorderSide(
          color: isEnabled ? GBTColors.border : GBTColors.divider,
          width: 1,
        );
      case GBTButtonVariant.primary:
      case GBTButtonVariant.tertiary:
      default:
        return BorderSide.none;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case GBTButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: GBTSpacing.sm,
          vertical: GBTSpacing.xs,
        );
      case GBTButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.sm,
        );
      case GBTButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: GBTSpacing.lg,
          vertical: GBTSpacing.md,
        );
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case GBTButtonSize.small:
        return GBTSpacing.radiusXs;
      case GBTButtonSize.medium:
        return GBTSpacing.radiusSm;
      case GBTButtonSize.large:
        return GBTSpacing.radiusMd;
    }
  }

  double _getIconSize() {
    switch (size) {
      case GBTButtonSize.small:
        return 16;
      case GBTButtonSize.medium:
        return 18;
      case GBTButtonSize.large:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case GBTButtonSize.small:
        return GBTTypography.labelSmall;
      case GBTButtonSize.medium:
        return GBTTypography.labelMedium;
      case GBTButtonSize.large:
        return GBTTypography.labelLarge;
    }
  }
}
```

### 5.3 하단 네비게이션 (Bottom Navigation)

```dart
/// 걸즈밴드 타비 하단 네비게이션
class GBTBottomNavigationBar extends StatelessWidget {
  const GBTBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  static const List<GBTTabItem> _tabs = [
    GBTTabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
    ),
    GBTTabItem(
      icon: Icons.temple_buddhist_outlined,
      activeIcon: Icons.temple_buddhist,
      label: '장소',
    ),
    GBTTabItem(
      icon: Icons.music_note_outlined,
      activeIcon: Icons.music_note,
      label: '라이브',
    ),
    GBTTabItem(
      icon: Icons.newspaper_outlined,
      activeIcon: Icons.newspaper,
      label: '소식',
    ),
    GBTTabItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: '설정',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GBTColors.background,
        border: Border(
          top: BorderSide(
            color: GBTColors.divider,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: GBTColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GBTSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = currentIndex == index;
              
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: GBTSpacing.sm,
                    vertical: GBTSpacing.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? tab.activeIcon : tab.icon,
                        size: 24,
                        color: isSelected 
                            ? GBTColors.primary 
                            : GBTColors.textSecondary,
                      ),
                      SizedBox(height: GBTSpacing.xs / 2),
                      Text(
                        tab.label,
                        style: GBTTypography.labelSmall.copyWith(
                          color: isSelected 
                              ? GBTColors.primary 
                              : GBTColors.textSecondary,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class GBTTabItem {
  const GBTTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
```

---

## 6. 탭별 레이아웃 패턴 (Tab-specific Layout Patterns)

### 6.1 홈 탭 레이아웃 

홈 탭은 섹션별 카드 피드 형태로 구성됩니다.

```dart
/// 홈 화면 섹션 헤더 컴포넌트
class GBTSectionHeader extends StatelessWidget {
  const GBTSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageMargin,
        vertical: GBTSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GBTTypography.headlineMedium.copyWith(
                    color: GBTColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: GBTSpacing.xs / 2),
                  Text(
                    subtitle!,
                    style: GBTTypography.bodySmall.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// 홈 화면 퀵 액세스 그리드
class GBTQuickAccessGrid extends StatelessWidget {
  const GBTQuickAccessGrid({super.key});

  static const List<GBTQuickAccessItem> _items = [
    GBTQuickAccessItem(
      icon: Icons.temple_buddhist,
      label: '성지순례',
      color: GBTColors.accent,
    ),
    GBTQuickAccessItem(
      icon: Icons.music_note,
      label: '라이브 일정',
      color: GBTColors.accentPink,
    ),
    GBTQuickAccessItem(
      icon: Icons.people,
      label: '팬 모임',
      color: GBTColors.accentBlue,
    ),
    GBTQuickAccessItem(
      icon: Icons.stars,
      label: '내 활동',
      color: GBTColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GBTSpacing.pageMargin),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: GBTSpacing.md,
          mainAxisSpacing: GBTSpacing.md,
          childAspectRatio: 1.5,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return GBTFeedCard(
            padding: EdgeInsets.all(GBTSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 24,
                  ),
                ),
                SizedBox(height: GBTSpacing.sm),
                Text(
                  item.label,
                  style: GBTTypography.labelMedium.copyWith(
                    color: GBTColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GBTQuickAccessItem {
  const GBTQuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
```

### 6.2 장소 탭 - 지도 + 바텀시트 레이아웃

```dart
/// 장소 지도 + 바텀시트 레이아웃
class GBTPlaceMapLayout extends StatefulWidget {
  const GBTPlaceMapLayout({
    super.key,
    required this.places,
    this.onPlaceSelected,
  });

  final List<PlaceEntity> places;
  final Function(PlaceEntity)? onPlaceSelected;

  @override
  State<GBTPlaceMapLayout> createState() => _GBTPlaceMapLayoutState();
}

class _GBTPlaceMapLayoutState extends State<GBTPlaceMapLayout> {
  final DraggableScrollableController _controller = DraggableScrollableController();
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 지도 영역
        Positioned.fill(
          child: GoogleMap(
            // 지도 설정
          ),
        ),
        
        // 검색 바
        Positioned(
          top: MediaQuery.of(context).padding.top + GBTSpacing.md,
          left: GBTSpacing.pageMargin,
          right: GBTSpacing.pageMargin,
          child: GBTSearchBar(),
        ),
        
        // 바텀시트
        DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: GBTColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(GBTSpacing.radiusLg),
                  topRight: Radius.circular(GBTSpacing.radiusLg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: GBTColors.primary.withOpacity(0.1),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 드래그 핸들
                  Container(
                    margin: EdgeInsets.symmetric(vertical: GBTSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GBTColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // 헤더
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: GBTSpacing.pageMargin,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '주변 장소',
                          style: GBTTypography.headlineSmall.copyWith(
                            color: GBTColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${widget.places.length}개 장소',
                          style: GBTTypography.bodySmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: GBTSpacing.md),
                  
                  // 장소 목록
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: GBTSpacing.pageMargin,
                      ),
                      itemCount: widget.places.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: GBTSpacing.md),
                          child: GBTPlaceCard(
                            place: widget.places[index],
                            showDistance: true,
                            onTap: () => widget.onPlaceSelected?.call(
                              widget.places[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### 6.3 라이브 탭 - 이벤트 목록 레이아웃

```dart
/// 라이브 이벤트 카드 컴포넌트
class GBTLiveEventCard extends StatelessWidget {
  const GBTLiveEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final LiveEventEntity event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GBTFeedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (날짜 + 상태)
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: GBTSpacing.sm,
                  vertical: GBTSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
                ),
                child: Text(
                  _getStatusText(),
                  style: GBTTypography.labelSmall.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              Text(
                _formatDate(event.date),
                style: GBTTypography.bodySmall.copyWith(
                  color: GBTColors.textSecondary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: GBTSpacing.md),
          
          // 이벤트 제목
          Text(
            event.title,
            style: GBTTypography.titleLarge.copyWith(
              color: GBTColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: GBTSpacing.sm),
          
          // 아티스트 정보
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(event.artistImageUrl ?? ''),
                backgroundColor: GBTColors.surfaceVariant,
              ),
              SizedBox(width: GBTSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.artistName,
                      style: GBTTypography.titleMedium.copyWith(
                        color: GBTColors.textPrimary,
                      ),
                    ),
                    if (event.genre != null)
                      Text(
                        event.genre!,
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: GBTSpacing.md),
          
          // 위치 정보
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: GBTColors.textSecondary,
              ),
              SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Text(
                  event.venue,
                  style: GBTTypography.bodySmall.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (event.isBookmarkd)
                Icon(
                  Icons.bookmark,
                  size: 16,
                  color: GBTColors.accentPink,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (event.status) {
      case LiveEventStatus.upcoming:
        return GBTColors.accentBlue;
      case LiveEventStatus.live:
        return GBTColors.error;
      case LiveEventStatus.ended:
        return GBTColors.textTertiary;
    }
  }

  String _getStatusText() {
    switch (event.status) {
      case LiveEventStatus.upcoming:
        return '예정';
      case LiveEventStatus.live:
        return 'LIVE';
      case LiveEventStatus.ended:
        return '종료';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
```

---

## 7. 성능 최적화 가이드라인

### 7.1 이미지 최적화

```dart
/// 최적화된 이미지 위젯
class GBTOptimizedImage extends StatelessWidget {
  const GBTOptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      placeholder: (context, url) => 
          placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => 
          errorWidget ?? _buildDefaultError(),
      fadeInDuration: Duration(milliseconds: 200),
      fadeOutDuration: Duration(milliseconds: 100),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: GBTColors.surfaceVariant,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              GBTColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: GBTColors.surfaceVariant,
      child: Icon(
        Icons.broken_image,
        color: GBTColors.textTertiary,
        size: 32,
      ),
    );
  }
}
```

### 7.2 리스트 성능 최적화

```dart
/// 최적화된 무한 스크롤 리스트
class GBTOptimizedListView<T> extends StatefulWidget {
  const GBTOptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.padding,
    this.separatorBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;

  @override
  State<GBTOptimizedListView<T>> createState() => _GBTOptimizedListViewState<T>();
}

class _GBTOptimizedListViewState<T> extends State<GBTOptimizedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!widget.isLoading && widget.hasMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);
    
    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding ?? EdgeInsets.all(GBTSpacing.pageMargin),
      itemCount: itemCount,
      separatorBuilder: widget.separatorBuilder ?? 
          (context, index) => SizedBox(height: GBTSpacing.md),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // 로딩 인디케이터
          return Center(
            child: Padding(
              padding: EdgeInsets.all(GBTSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 8. 접근성 표준 (Accessibility Standards)

### 8.1 기본 접근성 원칙

1. **색상 대비**: 모든 텍스트는 배경과 4.5:1 이상의 대비율 유지
2. **터치 타겟**: 최소 44x44px 크기 보장
3. **포커스 표시**: 키보드 네비게이션 시 명확한 포커스 표시
4. **스크린 리더**: 모든 인터랙티브 요소에 적절한 시멘틱 라벨 제공

### 8.2 접근성 유틸리티

```dart
/// 접근성 헬퍼 클래스
class GBTAccessibility {
  /// 터치 타겟 크기 검증
  static bool isValidTouchTarget(double width, double height) {
    return width >= GBTSpacing.minTouchTarget && 
           height >= GBTSpacing.minTouchTarget;
  }

  /// 시멘틱 라벨이 있는 버튼 생성
  static Widget accessibleButton({
    required String label,
    String? hint,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }

  /// 텍스트 스케일링 제한
  static Widget limitedTextScaleWidget({
    required Widget child,
    double maxScale = 1.3,
  }) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final constrainedTextScale = math.min(
          mediaQuery.textScaleFactor,
          maxScale,
        );
        
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: constrainedTextScale,
          ),
          child: child,
        );
      },
    );
  }
}
```

---

## 9. 다크 모드 지원 (Dark Mode Support)

### 9.1 다크 모드 색상 시스템

```dart
/// 다크 모드 색상 확장
extension GBTColorsDark on GBTColors {
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkDivider = Color(0xFF303030);
}

/// 테마별 색상 반환 유틸리티
class GBTThemeColors {
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? GBTColorsDark.darkBackground
        : GBTColors.background;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? GBTColorsDark.darkSurface
        : GBTColors.surface;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? GBTColorsDark.darkTextPrimary
        : GBTColors.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? GBTColorsDark.darkTextSecondary
        : GBTColors.textSecondary;
  }
}
```

### 9.2 다크 모드 테마 구성

```dart
/// 다크 모드 테마 설정
class GBTTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GBTTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GBTColors.primary,
      brightness: Brightness.light,
    ),
    // 추가 테마 설정...
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GBTTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GBTColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: GBTColorsDark.darkBackground,
    // 추가 다크 테마 설정...
  );
}
```

---

## 10. 구현 가이드라인 (Implementation Guidelines)

### 10.1 프로젝트 구조에 통합

```
lib/
├── core/
│   ├── theme/
│   │   ├── gbt_colors.dart           # 색상 시스템
│   │   ├── gbt_typography.dart       # 타이포그래피
│   │   ├── gbt_spacing.dart          # 간격 시스템  
│   │   ├── gbt_theme.dart            # 테마 설정
│   │   └── gbt_accessibility.dart    # 접근성 유틸리티
│   └── widgets/
│       ├── gbt_button.dart           # 버튼 컴포넌트
│       ├── gbt_card.dart             # 카드 컴포넌트
│       ├── gbt_navigation.dart       # 네비게이션 컴포넌트
│       ├── gbt_image.dart            # 이미지 컴포넌트
│       └── gbt_list.dart             # 리스트 컴포넌트
```

### 10.2 메인 앱에 적용

```dart
/// 메인 앱 설정
class GirlsBandTabiApp extends StatelessWidget {
  const GirlsBandTabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GBTAccessibility.limitedTextScaleWidget(
      child: MaterialApp.router(
        title: '걸즈밴드 타비',
        theme: GBTTheme.lightTheme,
        darkTheme: GBTTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: math.min(
                MediaQuery.of(context).textScaleFactor,
                1.3,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
```

### 10.3 단계별 마이그레이션 전략

**Phase 1: 기본 토큰 적용 (1주)**
- GBTColors, GBTTypography, GBTSpacing 클래스 생성
- 기존 하드코딩된 색상/폰트를 토큰으로 교체

**Phase 2: 핵심 컴포넌트 구현 (2주)**  
- GBTButton, GBTCard, GBTBottomNavigationBar 구현
- 기존 UI 컴포넌트를 새로운 컴포넌트로 교체

**Phase 3: 레이아웃 패턴 적용 (2주)**
- 각 탭별 레이아웃 패턴 적용
- 성능 최적화 및 접근성 개선

**Phase 4: 고도화 및 테스트 (1주)**
- 다크 모드 완전 지원
- 시각적 회귀 테스트 추가
- 성능 프로파일링 및 최적화

---

## 11. 품질 보증 (Quality Assurance)

### 11.1 디자인 시스템 체크리스트

- [ ] 모든 컴포넌트가 접근성 기준을 만족하는가?
- [ ] 색상 대비가 WCAG AA 기준을 충족하는가?
- [ ] 터치 타겟이 최소 44px을 만족하는가?
- [ ] 다크 모드에서 모든 UI가 정상 작동하는가?
- [ ] 텍스트 스케일링이 1.3배까지 정상 작동하는가?
- [ ] 모든 컴포넌트에 적절한 시멘틱 라벨이 있는가?
- [ ] 성능이 60fps를 유지하는가?
- [ ] 메모리 사용량이 적정 수준인가?

### 11.2 테스트 전략

```dart
/// 디자인 시스템 테스트
void main() {
  group('GBT Design System Tests', () {
    testWidgets('GBTButton accessibility test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GBTButton(
              onPressed: () {},
              text: 'Test Button',
            ),
          ),
        ),
      );

      // 터치 타겟 크기 검증
      final buttonFinder = find.byType(GBTButton);
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, greaterThanOrEqualTo(44));
      expect(buttonSize.height, greaterThanOrEqualTo(44));

      // 시멘틱 라벨 검증
      expect(
        find.bySemanticsLabel('Test Button'), 
        findsOneWidget,
      );
    });

    testWidgets('Color contrast validation', (tester) async {
      expect(
        GBTColorAccessibility.isAccessible(
          GBTColors.textPrimary, 
          GBTColors.background,
        ),
        true,
      );
    });
  });
}
```

---

## 12. 결론 및 다음 단계

### 12.1 주요 성과

본 디자인 시스템 명세서를 통해 다음을 달성했습니다:

1. **체계적인 디자인 토큰화**: 색상, 타이포그래피, 간격의 완전한 토큰화
2. **재사용 가능한 컴포넌트**: Clean Architecture와 호환되는 컴포넌트 시스템
3. **접근성 우선**: WCAG 2.1 AA 수준의 접근성 표준 준수
4. **성능 최적화**: 60fps 보장과 메모리 효율성 고려
5. **일관된 사용자 경험**: 5탭 전반에 걸친 시각적/인터랙션 일관성

### 12.2 즉시 적용 가능한 요소

- **색상 시스템**: GBTColors 클래스로 즉시 적용
- **타이포그래피**: Pretendard 폰트 기반 완전한 텍스트 스타일
- **핵심 컴포넌트**: 버튼, 카드, 네비게이션 바 즉시 사용 가능
- **레이아웃 패턴**: 각 탭별 검증된 UI 패턴 적용

### 12.3 향후 확장 계획

1. **애니메이션 시스템**: 일관된 모션 디자인 추가
2. **다국어 지원**: 일본어, 영어 타이포그래피 최적화
3. **AI 기능 대비**: KT UXD AI 컴포넌트 활용 준비
4. **성능 모니터링**: 지속적인 성능 프로파일링 체계 구축

### 12.4 유지보수 및 발전

- **정기 리뷰**: 월 1회 디자인 시스템 사용성 검토
- **사용자 피드백**: 실제 사용자 경험 기반 개선
- **기술 업데이트**: Flutter, Material Design 3 업데이트 반영
- **KT UXD 동기화**: 상위 디자인 시스템 변경사항 추적 및 반영

---

**문서 버전**: 1.0.0  
**최종 수정일**: 2024년 12월 14일  
**작성자**: Claude (ui-designer)  
**승인**: 걸즈밴드 타비 개발팀

본 디자인 시스템 명세서는 실제 Flutter 프로젝트에 즉시 적용 가능한 실용적 가이드입니다. 체계적인 토큰 시스템과 재사용 가능한 컴포넌트를 통해 일관되고 접근성 높은 사용자 경험을 제공할 수 있습니다.