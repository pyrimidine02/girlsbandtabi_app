# KT UXD Design System - Component Specifications

## Overview

This document outlines the comprehensive design system for the 걸즈밴드타비 app based on the PDF design guidelines analysis. The system builds upon the existing KT theme foundation while introducing new components for the 5-tab structure and modern UI patterns.

## Design Principles

### 1. Card-Centric Design
- **Primary Pattern**: Card-based UI components for all content display
- **Inspiration**: CHZZK, Airbnb, Naver Maps UI patterns
- **Variants**: Feed cards, place cards, event cards, stats cards

### 2. Bottom Sheet Integration
- **Map Integration**: Map + bottom sheet pattern for place exploration
- **Detail Views**: Swipeable bottom sheets for additional information
- **Statistics**: Chart visualization in dedicated bottom sheet views

### 3. 5-Tab Navigation Structure
- **홈 (Home)**: Card feed with content aggregation
- **장소 (Places)**: Map-based exploration with bottom sheets
- **라이브 (Live)**: Event listings and performance schedules
- **정보 (Info/Community)**: Community feed and news aggregation
- **설정 (Settings)**: User profile and app configuration

## Component Architecture

```
lib/core/widgets/
├── cards/                  # Card component system
│   ├── base/              # Base card implementations
│   ├── feed/              # Home feed cards
│   ├── place/             # Place-specific cards
│   ├── event/             # Live event cards
│   └── stats/             # Statistics and chart cards
├── sheets/                # Bottom sheet components
│   ├── base/              # Base bottom sheet
│   ├── place_detail/      # Place information sheets
│   ├── statistics/        # Chart and stats sheets
│   └── filter/            # Filter and search sheets
├── navigation/            # Navigation components
│   ├── tab_bar/           # 5-tab navigation
│   ├── app_bar/           # Contextual app bars
│   └── breadcrumbs/       # Navigation breadcrumbs
├── charts/                # Data visualization
│   ├── bar_chart/         # Visit statistics
│   ├── line_chart/        # Trends over time
│   ├── pie_chart/         # Distribution charts
│   └── heat_map/          # Location heat maps
├── buttons/               # CTA and action buttons
│   ├── verification/      # Visit verification CTAs
│   ├── primary/           # Primary action buttons
│   └── floating/          # Floating action buttons
├── forms/                 # Enhanced form components
│   ├── search/            # Search input variants
│   ├── filters/           # Filter controls
│   └── inputs/            # Enhanced text inputs
└── feedback/              # User feedback components
    ├── success/           # Success states
    ├── loading/           # Loading indicators
    └── empty/             # Empty state displays
```

## Component Specifications

### 1. Card Components

#### KTFeedCard
**Purpose**: Home feed content aggregation
**Variants**: 
- `upcoming_events`: Upcoming live events preview
- `popular_places`: Popular pilgrimage locations
- `band_news`: Latest band news and updates
- `user_activity`: User-generated content

**Design Specs**:
```dart
// Base structure
KTFeedCard(
  variant: KTFeedCardVariant.upcomingEvents,
  title: "다가오는 라이브 이벤트",
  subtitle: "이번 주 추천 공연",
  content: List<EventSummary>,
  action: KTCardAction.viewAll,
  thumbnail: NetworkImage,
  onTap: () => Navigator.push(...),
)
```

#### KTPlaceCard
**Purpose**: Place information display
**Variants**:
- `list_item`: Compact list display
- `featured`: Large featured place
- `grid_item`: Grid layout item
- `detail_preview`: Bottom sheet preview

#### KTEventCard
**Purpose**: Live event information
**Variants**:
- `schedule_item`: Event schedule display
- `featured_event`: Highlighted events
- `statistics_summary`: Event stats preview

#### KTStatsCard
**Purpose**: Statistics visualization
**Variants**:
- `visit_counter`: Visit count display
- `chart_preview`: Chart with summary
- `achievement`: Achievement badges
- `leaderboard`: User rankings

### 2. Bottom Sheet Components

#### KTPlaceDetailSheet
**Features**:
- Place information display
- Photo gallery
- Visit verification CTA
- Statistics swipe view
- User reviews section

#### KTStatisticsSheet
**Features**:
- Interactive charts
- Visit trends
- Popular time analysis
- User activity heat maps

#### KTFilterSheet
**Features**:
- Search filters
- Sort options
- Range selectors
- Quick filter chips

### 3. Chart Components

#### KTBarChart
**Use Cases**:
- Visit statistics by location
- Monthly activity trends
- Band popularity rankings

#### KTLineChart
**Use Cases**:
- Visit trends over time
- Event attendance patterns
- User engagement metrics

#### KTPieChart
**Use Cases**:
- Visit distribution by band
- Location category breakdown
- User activity types

#### KTHeatMap
**Use Cases**:
- Location popularity visualization
- Visit time patterns
- Geographic clustering

### 4. CTA Button Patterns

#### KTVerificationButton
**Purpose**: Visit verification actions
**States**:
- `inactive`: Ready for verification
- `processing`: Verification in progress
- `completed`: Verification successful
- `failed`: Verification failed

**Design Specs**:
```dart
KTVerificationButton(
  location: Place,
  onVerify: () async {
    // GPS validation
    // Photo capture
    // Server verification
  },
  style: KTVerificationButtonStyle.primary,
  feedback: KTHapticFeedback.success,
)
```

### 5. Navigation System

#### KTTabBar
**Updated 5-tab structure**:
- 홈 (Home): `Icons.home` - Content feed
- 장소 (Places): `Icons.map` - Map exploration
- 라이브 (Live): `Icons.event` - Event listings
- 정보 (Info): `Icons.forum` - Community/News
- 설정 (Settings): `Icons.person` - Profile/Settings

## Theme Integration

### Color Scheme Extensions
```dart
extension KTCardColors on ColorScheme {
  // Card-specific colors
  Color get cardBackground => surface;
  Color get cardElevated => surfaceContainerHigh;
  Color get cardInteractive => surfaceContainerHighest;
  Color get cardBorder => outline.withValues(alpha: 0.2);
  
  // Chart colors
  List<Color> get chartPalette => [
    primary,
    secondary,
    tertiary,
    KTColors.statusPositive,
    KTColors.statusWarning,
  ];
}
```

### Typography Extensions
```dart
extension KTCardTypography on TextTheme {
  // Card typography
  TextStyle get cardTitle => titleMedium?.copyWith(
    fontWeight: KTTypography.semiBold,
  );
  
  TextStyle get cardSubtitle => bodyMedium?.copyWith(
    color: KTColors.textSecondary,
  );
  
  TextStyle get cardMeta => labelSmall?.copyWith(
    color: KTColors.textTertiary,
  );
}
```

### Spacing System Updates
```dart
class KTCardSpacing {
  // Card internal spacing
  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Chart spacing
  static const double chartPadding = 20.0;
  static const double chartMargin = 12.0;
  static const double chartLegendSpacing = 8.0;
}
```

## Animation Specifications

### Card Animations
```dart
class KTCardAnimations {
  static const Duration cardTap = Duration(milliseconds: 150);
  static const Duration cardHover = Duration(milliseconds: 200);
  static const Duration cardExpand = Duration(milliseconds: 300);
  static const Curve cardCurve = Curves.easeOutCubic;
}
```

### Sheet Animations
```dart
class KTSheetAnimations {
  static const Duration sheetSlide = Duration(milliseconds: 400);
  static const Duration sheetSnap = Duration(milliseconds: 200);
  static const Curve sheetCurve = Curves.fastOutSlowIn;
}
```

## Accessibility Guidelines

### Semantic Labels
- All cards must have descriptive semantic labels
- Chart components require data table alternatives
- Bottom sheets need proper navigation announcements

### Touch Targets
- Minimum 44x44pt touch targets
- Card actions must be clearly defined
- Swipe gestures require haptic feedback

### Color Contrast
- All text meets WCAG 2.1 AA standards
- Chart colors maintain 3:1 contrast ratio
- Interactive elements have visible focus indicators

## Implementation Priority

### Phase 1: Core Cards (Weeks 1-2)
- Base card infrastructure
- Feed card variants
- Place card implementations

### Phase 2: Navigation & Sheets (Weeks 3-4)
- Updated 5-tab navigation
- Basic bottom sheet system
- Place detail sheets

### Phase 3: Charts & Visualization (Weeks 5-6)
- Chart component library
- Statistics integration
- Data visualization sheets

### Phase 4: Advanced Features (Weeks 7-8)
- CTA button patterns
- Advanced animations
- Performance optimizations

## Testing Strategy

### Component Testing
- Unit tests for all card variants
- Widget tests for bottom sheet interactions
- Integration tests for navigation flows

### Visual Testing
- Screenshot tests for card layouts
- Theme variation testing
- Responsive design validation

### Accessibility Testing
- Screen reader compatibility
- Voice control support
- High contrast mode validation

## Migration Plan

### Backward Compatibility
- Existing KT components remain functional
- Gradual migration path for legacy screens
- Progressive enhancement approach

### Data Migration
- Chart data formatting updates
- Card content model adjustments
- Navigation state management updates

---

This design system provides a comprehensive foundation for implementing the PDF design guidelines while maintaining the existing KT UXD standards and ensuring scalability for future enhancements.