# KT UXD Component Implementation Specifications for Girls Band Tabi

## Overview

This document provides detailed implementation specifications for all 16 core KT UXD components and 5 AI Agent components, specifically adapted for the Girls Band Tabi music pilgrimage application.

---

## 1. Core KT UXD Components (16 Components)

### 1.1 KT Bottom Navigation
**Purpose**: Main app navigation with music-context awareness  
**Location**: `lib/widgets/kt_components/kt_bottom_navigation.dart`

```dart
/// EN: KT UXD bottom navigation with music context and live status indicators
/// KO: 음악 컨텍스트와 실시간 상태 표시기를 갖춘 KT UXD 하단 네비게이션
class KTBottomNavigation extends StatelessWidget {
  const KTBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLiveBadge = false,
    this.liveEventCount = 0,
  });

  final int currentIndex;
  final Function(int) onTap;
  final bool showLiveBadge;
  final int liveEventCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KTColors.surface,
        border: Border(top: BorderSide(color: KTColors.border)),
        boxShadow: [
          BoxShadow(
            color: KTColors.shadow,
            blurRadius: KTSpacing.elevationLg,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.event_outlined,
                activeIcon: Icons.event,
                label: 'Live',
                index: 1,
                isActive: currentIndex == 1,
                showBadge: showLiveBadge,
                badgeCount: liveEventCount,
              ),
              _buildNavItem(
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
                label: 'Pilgrimage',
                index: 2,
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                isActive: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: KTSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? KTColors.ktPrimary : KTColors.iconSecondary,
                    size: 24,
                  ),
                  if (showBadge && badgeCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: KTColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: KTTypography.labelSmall.copyWith(
                            color: KTColors.textOnDark,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: KTSpacing.xxs),
              Text(
                label,
                style: KTTypography.labelSmall.copyWith(
                  color: isActive ? KTColors.ktPrimary : KTColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 1.2 KT Bottom Sheet
**Purpose**: Modal content presentation with music-specific layouts  
**Location**: `lib/widgets/kt_components/kt_bottom_sheet.dart`

```dart
/// EN: KT UXD bottom sheet with music content optimization
/// KO: 음악 콘텐츠 최적화를 갖춘 KT UXD 하단 시트
class KTBottomSheet extends StatelessWidget {
  const KTBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.showCloseButton = false,
    this.isDraggable = true,
    this.enableDrag = true,
    this.backgroundColor,
    this.maxHeight,
  });

  final Widget child;
  final String? title;
  final bool showHandle;
  final bool showCloseButton;
  final bool isDraggable;
  final bool enableDrag;
  final Color? backgroundColor;
  final double? maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool showCloseButton = false,
    bool isDraggable = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? maxHeight,
    bool useRootNavigator = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => KTBottomSheet(
        title: title,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        isDraggable: isDraggable,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        maxHeight: maxHeight,
        child: child,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double defaultMaxHeight = screenHeight * 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? defaultMaxHeight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? KTColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(KTSpacing.radiusLg),
          topRight: Radius.circular(KTSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: KTColors.shadow,
            blurRadius: KTSpacing.elevationXl,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // EN: Handle and header
          // KO: 핸들 및 헤더
          Container(
            padding: EdgeInsets.fromLTRB(
              KTSpacing.md,
              showHandle ? KTSpacing.sm : KTSpacing.md,
              KTSpacing.md,
              title != null ? KTSpacing.sm : 0,
            ),
            child: Column(
              children: [
                if (showHandle)
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: KTSpacing.sm),
                    decoration: BoxDecoration(
                      color: KTColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (title != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: KTTypography.headlineSmall.copyWith(
                            color: KTColors.textPrimary,
                          ),
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: KTColors.iconSecondary,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          
          // EN: Content
          // KO: 콘텐츠
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                KTSpacing.md,
                0,
                KTSpacing.md,
                KTSpacing.md,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Specialized bottom sheet for music content (album info, artist details, etc.)
/// KO: 음악 콘텐츠 전용 하단 시트 (앨범 정보, 아티스트 세부사항 등)
class KTMusicBottomSheet extends StatelessWidget {
  const KTMusicBottomSheet({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.content,
    this.actions,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return KTBottomSheet(
      showHandle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN: Music header with image
          // KO: 이미지가 있는 음악 헤더
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: KTColors.surfaceAlternate,
                      child: Icon(
                        Icons.music_note,
                        color: KTColors.iconSecondary,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: KTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: KTTypography.headlineSmall.copyWith(
                        color: KTColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: KTSpacing.xxs),
                    Text(
                      subtitle,
                      style: KTTypography.bodyMedium.copyWith(
                        color: KTColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: KTSpacing.lg),
          
          // EN: Content
          // KO: 콘텐츠
          content,
          
          // EN: Actions
          // KO: 액션 버튼들
          if (actions != null) ...[
            SizedBox(height: KTSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
```

### 1.3 KT Enhanced Search
**Purpose**: AI-powered search with music-specific features  
**Location**: `lib/widgets/kt_components/kt_search.dart`

```dart
/// EN: KT UXD search component with AI enhancement and music context
/// KO: AI 향상과 음악 컨텍스트를 갖춘 KT UXD 검색 컴포넌트
class KTSearch extends StatefulWidget {
  const KTSearch({
    super.key,
    required this.onSearch,
    this.onSuggestionTap,
    this.onVoiceSearch,
    this.placeholder = 'Search places, bands, events...',
    this.showVoiceButton = true,
    this.showFilters = true,
    this.enableAI = true,
    this.suggestions = const [],
    this.recentSearches = const [],
  });

  final Function(String query) onSearch;
  final Function(String suggestion)? onSuggestionTap;
  final VoidCallback? onVoiceSearch;
  final String placeholder;
  final bool showVoiceButton;
  final bool showFilters;
  final bool enableAI;
  final List<String> suggestions;
  final List<String> recentSearches;

  @override
  State<KTSearch> createState() => _KTSearchState();
}

class _KTSearchState extends State<KTSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onQueryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // EN: Main search bar
        // KO: 메인 검색바
        Container(
          decoration: BoxDecoration(
            color: KTColors.surfaceAlternate,
            borderRadius: BorderRadius.circular(KTSpacing.radiusLg),
            border: _focusNode.hasFocus 
              ? Border.all(color: KTColors.ktPrimary, width: 2)
              : Border.all(color: KTColors.border),
          ),
          child: Row(
            children: [
              // EN: Search icon
              // KO: 검색 아이콘
              Padding(
                padding: EdgeInsets.only(left: KTSpacing.md),
                child: Icon(
                  Icons.search,
                  color: KTColors.iconSecondary,
                  size: 20,
                ),
              ),
              
              // EN: Search input
              // KO: 검색 입력
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: KTTypography.bodyMedium.copyWith(
                    color: KTColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: KTTypography.bodyMedium.copyWith(
                      color: KTColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: KTSpacing.sm,
                      vertical: KTSpacing.md,
                    ),
                  ),
                  onSubmitted: widget.onSearch,
                ),
              ),
              
              // EN: AI indicator
              // KO: AI 표시기
              if (widget.enableAI)
                Padding(
                  padding: EdgeInsets.only(right: KTSpacing.xs),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: KTSpacing.xs,
                      vertical: KTSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: KTColors.ktPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KTSpacing.radiusXs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: KTColors.ktPrimary,
                          size: 12,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'AI',
                          style: KTTypography.labelSmall.copyWith(
                            color: KTColors.ktPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // EN: Voice search button
              // KO: 음성 검색 버튼
              if (widget.showVoiceButton)
                IconButton(
                  onPressed: widget.onVoiceSearch,
                  icon: Icon(
                    Icons.mic_outlined,
                    color: KTColors.iconSecondary,
                  ),
                ),
              
              // EN: Filter button
              // KO: 필터 버튼
              if (widget.showFilters)
                IconButton(
                  onPressed: _toggleFilters,
                  icon: Icon(
                    Icons.tune,
                    color: KTColors.iconSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        // EN: Suggestions and recent searches
        // KO: 제안 및 최근 검색
        if (_isExpanded && _focusNode.hasFocus)
          _buildSuggestions(),
      ],
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: EdgeInsets.only(top: KTSpacing.xs),
      decoration: BoxDecoration(
        color: KTColors.surface,
        borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
        border: Border.all(color: KTColors.border),
        boxShadow: [
          BoxShadow(
            color: KTColors.shadow,
            blurRadius: KTSpacing.elevationSm,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN: AI suggestions
          // KO: AI 제안
          if (_filteredSuggestions.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(KTSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: KTColors.ktPrimary,
                    size: 16,
                  ),
                  SizedBox(width: KTSpacing.xs),
                  Text(
                    'AI Suggestions',
                    style: KTTypography.labelMedium.copyWith(
                      color: KTColors.ktPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ..._filteredSuggestions.take(3).map((suggestion) =>
              _buildSuggestionTile(suggestion, Icons.auto_awesome_outlined),
            ),
            if (widget.recentSearches.isNotEmpty)
              Divider(color: KTColors.dividerColor),
          ],
          
          // EN: Recent searches
          // KO: 최근 검색
          if (widget.recentSearches.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(KTSpacing.sm),
              child: Text(
                'Recent Searches',
                style: KTTypography.labelMedium.copyWith(
                  color: KTColors.textSecondary,
                ),
              ),
            ),
            ...widget.recentSearches.take(3).map((search) =>
              _buildSuggestionTile(search, Icons.history),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(String text, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: KTColors.iconTertiary,
        size: 16,
      ),
      title: Text(
        text,
        style: KTTypography.bodyMedium.copyWith(
          color: KTColors.textPrimary,
        ),
      ),
      onTap: () => _selectSuggestion(text),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _onFocusChanged() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  void _onQueryChanged() {
    final query = _controller.text;
    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    widget.onSuggestionTap?.call(suggestion);
    _focusNode.unfocus();
  }

  void _toggleFilters() {
    // EN: Implement filter toggle logic
    // KO: 필터 토글 로직 구현
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

---

## 2. AI Agent Components (5 Components)

### 2.1 KT AI Navigation Bar
**Purpose**: Context-aware navigation with AI conversation management  
**Location**: `lib/widgets/kt_ai_components/kt_ai_navigation_bar.dart`

```dart
/// EN: AI-specific navigation bar with contextual awareness for music pilgrimage
/// KO: 음악 성지순례용 컨텍스트 인식 AI 전용 네비게이션 바
class KTAINavigationBar extends StatelessWidget {
  const KTAINavigationBar({
    super.key,
    required this.onConversationChanged,
    required this.conversations,
    this.currentConversationId,
    this.onNewConversation,
    this.onClearContext,
    this.aiMode = AIMode.assistant,
    this.showMusicContext = true,
  });

  final Function(String conversationId) onConversationChanged;
  final List<AIConversation> conversations;
  final String? currentConversationId;
  final VoidCallback? onNewConversation;
  final VoidCallback? onClearContext;
  final AIMode aiMode;
  final bool showMusicContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KTColors.ktPrimary.withOpacity(0.05),
            KTColors.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: KTColors.ktPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: KTSpacing.md),
          child: Row(
            children: [
              // EN: AI mode indicator with music context
              // KO: 음악 컨텍스트와 함께한 AI 모드 표시기
              _buildAIModeIndicator(),
              
              SizedBox(width: KTSpacing.sm),
              
              // EN: Conversation tabs
              // KO: 대화 탭
              Expanded(
                child: _buildConversationTabs(),
              ),
              
              // EN: Action buttons
              // KO: 액션 버튼
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIModeIndicator() {
    IconData icon;
    Color color;
    String label;
    
    switch (aiMode) {
      case AIMode.pilgrimage:
        icon = Icons.location_on;
        color = KTColors.success;
        label = 'Pilgrimage AI';
        break;
      case AIMode.music:
        icon = Icons.music_note;
        color = KTColors.ktSecondary;
        label = 'Music AI';
        break;
      case AIMode.event:
        icon = Icons.event;
        color = KTColors.error;
        label = 'Event AI';
        break;
      default:
        icon = Icons.auto_awesome;
        color = KTColors.ktPrimary;
        label = 'AI Assistant';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KTSpacing.sm,
        vertical: KTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KTSpacing.radiusLg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: KTSpacing.xs),
          Text(
            label,
            style: KTTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTabs() {
    if (conversations.isEmpty) {
      return Center(
        child: Text(
          'Start a new conversation',
          style: KTTypography.bodySmall.copyWith(
            color: KTColors.textTertiary,
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final isSelected = conversation.id == currentConversationId;
          
          return Padding(
            padding: EdgeInsets.only(right: KTSpacing.xs),
            child: GestureDetector(
              onTap: () => onConversationChanged(conversation.id),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: KTSpacing.sm,
                  vertical: KTSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? KTColors.ktPrimary
                      : KTColors.surfaceAlternate,
                  borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
                  border: isSelected
                      ? null
                      : Border.all(color: KTColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (conversation.type == ConversationType.music)
                      Icon(
                        Icons.music_note,
                        size: 14,
                        color: isSelected 
                          ? KTColors.textOnDark 
                          : KTColors.iconSecondary,
                      ),
                    if (conversation.type == ConversationType.pilgrimage)
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isSelected 
                          ? KTColors.textOnDark 
                          : KTColors.iconSecondary,
                      ),
                    if (conversation.type == ConversationType.general)
                      Icon(
                        Icons.chat,
                        size: 14,
                        color: isSelected 
                          ? KTColors.textOnDark 
                          : KTColors.iconSecondary,
                      ),
                    SizedBox(width: KTSpacing.xxs),
                    Text(
                      conversation.title,
                      style: KTTypography.labelSmall.copyWith(
                        color: isSelected 
                          ? KTColors.textOnDark 
                          : KTColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EN: Clear context button
        // KO: 컨텍스트 지우기 버튼
        if (onClearContext != null)
          IconButton(
            onPressed: onClearContext,
            icon: Icon(
              Icons.clear_all,
              color: KTColors.iconSecondary,
              size: 20,
            ),
            tooltip: 'Clear context',
          ),
        
        // EN: New conversation button
        // KO: 새 대화 버튼
        if (onNewConversation != null)
          IconButton(
            onPressed: onNewConversation,
            icon: Icon(
              Icons.add,
              color: KTColors.iconSecondary,
              size: 20,
            ),
            tooltip: 'New conversation',
          ),
      ],
    );
  }
}

/// EN: AI conversation data model
/// KO: AI 대화 데이터 모델
class AIConversation {
  final String id;
  final String title;
  final ConversationType type;
  final DateTime createdAt;
  final List<AIMessage> messages;
  final Map<String, dynamic>? musicContext;
  
  const AIConversation({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.messages,
    this.musicContext,
  });
}

enum AIMode {
  assistant,
  pilgrimage,
  music,
  event,
}

enum ConversationType {
  general,
  music,
  pilgrimage,
  event,
}
```

### 2.2 KT AI Prompt Input Field
**Purpose**: Advanced AI interaction with music-specific context  
**Location**: `lib/widgets/kt_ai_components/kt_ai_prompt_field.dart`

```dart
/// EN: Advanced AI prompt input field with music context and smart suggestions
/// KO: 음악 컨텍스트와 스마트 제안을 갖춘 고급 AI 프롬프트 입력 필드
class KTAIPromptField extends StatefulWidget {
  const KTAIPromptField({
    super.key,
    required this.onSubmit,
    this.placeholder = 'Ask AI about music, places, or events...',
    this.isLoading = false,
    this.maxLength = 500,
    this.supportedFeatures = const [],
    this.musicContext,
    this.locationContext,
    this.showQuickPrompts = true,
    this.enableVoiceInput = true,
  });

  final Function(String prompt, {Map<String, dynamic>? context}) onSubmit;
  final String placeholder;
  final bool isLoading;
  final int maxLength;
  final List<AIFeature> supportedFeatures;
  final MusicContext? musicContext;
  final LocationContext? locationContext;
  final bool showQuickPrompts;
  final bool enableVoiceInput;

  @override
  State<KTAIPromptField> createState() => _KTAIPromptFieldState();
}

class _KTAIPromptFieldState extends State<KTAIPromptField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _currentSuggestions = [];

  // EN: Quick prompt templates for music pilgrimage
  // KO: 음악 성지순례용 빠른 프롬프트 템플릿
  static const List<QuickPrompt> _quickPrompts = [
    QuickPrompt(
      icon: Icons.location_on,
      text: 'Plan a pilgrimage route',
      template: 'Plan a pilgrimage route for {band} in {location}',
      category: PromptCategory.pilgrimage,
    ),
    QuickPrompt(
      icon: Icons.event,
      text: 'Find upcoming events',
      template: 'Show me upcoming {band} events near {location}',
      category: PromptCategory.events,
    ),
    QuickPrompt(
      icon: Icons.music_note,
      text: 'Discover music places',
      template: 'Find places related to {genre} music in {location}',
      category: PromptCategory.discovery,
    ),
    QuickPrompt(
      icon: Icons.route,
      text: 'Optimize my route',
      template: 'Optimize my route for visiting these places: {places}',
      category: PromptCategory.optimization,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KTSpacing.md),
      decoration: BoxDecoration(
        color: KTColors.surface,
        borderRadius: BorderRadius.circular(KTSpacing.radiusXl),
        border: Border.all(
          color: _focusNode.hasFocus 
            ? KTColors.ktPrimary 
            : KTColors.border,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          if (_focusNode.hasFocus)
            BoxShadow(
              color: KTColors.ktPrimary.withOpacity(0.1),
              blurRadius: KTSpacing.elevationMd,
              offset: Offset(0, 2),
            )
          else
            BoxShadow(
              color: KTColors.shadow,
              blurRadius: KTSpacing.elevationSm,
              offset: Offset(0, 1),
            ),
        ],
      ),
      child: Column(
        children: [
          // EN: Context indicators
          // KO: 컨텍스트 표시기
          if (_hasActiveContext()) _buildContextIndicators(),
          
          // EN: Feature toggles
          // KO: 기능 토글
          if (widget.supportedFeatures.isNotEmpty && _focusNode.hasFocus)
            _buildFeatureToggles(),
          
          // EN: Main input area
          // KO: 메인 입력 영역
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // EN: Input field
              // KO: 입력 필드
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  maxLength: widget.maxLength,
                  enabled: !widget.isLoading,
                  style: KTTypography.bodyMedium.copyWith(
                    color: KTColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: KTTypography.bodyMedium.copyWith(
                      color: KTColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  onSubmitted: _handleSubmit,
                ),
              ),
              
              SizedBox(width: KTSpacing.sm),
              
              // EN: Action buttons row
              // KO: 액션 버튼 행
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EN: Voice input button
                  // KO: 음성 입력 버튼
                  if (widget.enableVoiceInput)
                    IconButton(
                      onPressed: widget.isLoading ? null : _handleVoiceInput,
                      icon: Icon(
                        Icons.mic_outlined,
                        color: widget.isLoading 
                          ? KTColors.iconDisabled 
                          : KTColors.iconSecondary,
                        size: 20,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  
                  // EN: Submit button or loading indicator
                  // KO: 전송 버튼 또는 로딩 표시기
                  if (widget.isLoading)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          KTColors.ktPrimary,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _canSubmit() ? _handleSubmitButton : null,
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _canSubmit() 
                            ? KTColors.ktPrimary 
                            : KTColors.iconDisabled,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: KTColors.textOnDark,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          // EN: Quick prompts
          // KO: 빠른 프롬프트
          if (widget.showQuickPrompts && _focusNode.hasFocus)
            _buildQuickPrompts(),
        ],
      ),
    );
  }

  Widget _buildContextIndicators() {
    return Padding(
      padding: EdgeInsets.only(bottom: KTSpacing.sm),
      child: Row(
        children: [
          if (widget.musicContext != null) ...[
            _buildContextChip(
              icon: Icons.music_note,
              label: widget.musicContext!.bandName,
              color: KTColors.ktSecondary,
              onRemove: () {
                // EN: Remove music context
                // KO: 음악 컨텍스트 제거
              },
            ),
            SizedBox(width: KTSpacing.xs),
          ],
          if (widget.locationContext != null) ...[
            _buildContextChip(
              icon: Icons.location_on,
              label: widget.locationContext!.displayName,
              color: KTColors.success,
              onRemove: () {
                // EN: Remove location context
                // KO: 위치 컨텍스트 제거
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContextChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KTSpacing.sm,
        vertical: KTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: KTSpacing.xs),
          Text(
            label,
            style: KTTypography.labelSmall.copyWith(
              color: color,
            ),
          ),
          SizedBox(width: KTSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              color: color,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Padding(
      padding: EdgeInsets.only(top: KTSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Prompts',
            style: KTTypography.labelSmall.copyWith(
              color: KTColors.textSecondary,
            ),
          ),
          SizedBox(height: KTSpacing.xs),
          Wrap(
            spacing: KTSpacing.xs,
            runSpacing: KTSpacing.xs,
            children: _quickPrompts.map((prompt) {
              return GestureDetector(
                onTap: () => _selectQuickPrompt(prompt),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: KTSpacing.sm,
                    vertical: KTSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: KTColors.surfaceAlternate,
                    borderRadius: BorderRadius.circular(KTSpacing.radiusSm),
                    border: Border.all(color: KTColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        prompt.icon,
                        color: KTColors.iconSecondary,
                        size: 14,
                      ),
                      SizedBox(width: KTSpacing.xs),
                      Text(
                        prompt.text,
                        style: KTTypography.labelSmall.copyWith(
                          color: KTColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggles() {
    return Padding(
      padding: EdgeInsets.only(bottom: KTSpacing.sm),
      child: Row(
        children: widget.supportedFeatures.map((feature) {
          return Padding(
            padding: EdgeInsets.only(right: KTSpacing.sm),
            child: Chip(
              avatar: Icon(
                feature.icon,
                size: 16,
                color: feature.isEnabled 
                  ? KTColors.ktPrimary 
                  : KTColors.iconDisabled,
              ),
              label: Text(
                feature.displayName,
                style: KTTypography.labelSmall.copyWith(
                  color: feature.isEnabled 
                    ? KTColors.ktPrimary 
                    : KTColors.textDisabled,
                ),
              ),
              backgroundColor: feature.isEnabled
                ? KTColors.ktPrimary.withOpacity(0.1)
                : KTColors.surfaceAlternate,
              side: BorderSide(
                color: feature.isEnabled
                  ? KTColors.ktPrimary.withOpacity(0.3)
                  : KTColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasActiveContext() {
    return widget.musicContext != null || widget.locationContext != null;
  }

  bool _canSubmit() {
    return _controller.text.trim().isNotEmpty && !widget.isLoading;
  }

  void _handleSubmit(String value) {
    if (_canSubmit()) {
      final context = <String, dynamic>{};
      if (widget.musicContext != null) {
        context['music'] = widget.musicContext!.toJson();
      }
      if (widget.locationContext != null) {
        context['location'] = widget.locationContext!.toJson();
      }
      
      widget.onSubmit(value.trim(), context: context.isNotEmpty ? context : null);
      _controller.clear();
    }
  }

  void _handleSubmitButton() {
    _handleSubmit(_controller.text);
  }

  void _handleVoiceInput() {
    // EN: Implement voice input logic
    // KO: 음성 입력 로직 구현
  }

  void _selectQuickPrompt(QuickPrompt prompt) {
    String template = prompt.template;
    
    // EN: Replace placeholders with context
    // KO: 플레이스홀더를 컨텍스트로 교체
    if (widget.musicContext != null) {
      template = template.replaceAll('{band}', widget.musicContext!.bandName);
      template = template.replaceAll('{genre}', widget.musicContext!.genre ?? 'your favorite');
    }
    if (widget.locationContext != null) {
      template = template.replaceAll('{location}', widget.locationContext!.displayName);
    }
    
    _controller.text = template;
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    // EN: Implement smart suggestions based on input
    // KO: 입력 기반 스마트 제안 구현
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// EN: Supporting data classes
// KO: 지원 데이터 클래스들

class QuickPrompt {
  final IconData icon;
  final String text;
  final String template;
  final PromptCategory category;
  
  const QuickPrompt({
    required this.icon,
    required this.text,
    required this.template,
    required this.category,
  });
}

enum PromptCategory {
  pilgrimage,
  events,
  discovery,
  optimization,
}

class MusicContext {
  final String bandName;
  final String? genre;
  final String? album;
  final String? song;
  
  const MusicContext({
    required this.bandName,
    this.genre,
    this.album,
    this.song,
  });
  
  Map<String, dynamic> toJson() => {
    'bandName': bandName,
    'genre': genre,
    'album': album,
    'song': song,
  };
}

class LocationContext {
  final String displayName;
  final double? latitude;
  final double? longitude;
  final String? address;
  
  const LocationContext({
    required this.displayName,
    this.latitude,
    this.longitude,
    this.address,
  });
  
  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };
}

class AIFeature {
  final String id;
  final String displayName;
  final IconData icon;
  final bool isEnabled;
  
  const AIFeature({
    required this.id,
    required this.displayName,
    required this.icon,
    this.isEnabled = true,
  });
}
```

---

## 3. Implementation Priority Matrix

### High Priority (Phase 1 - Weeks 1-4)
1. **KT Bottom Navigation** - Critical app structure
2. **KT Button System** - Universal component
3. **KT Text Field** - Forms and search
4. **KT Search** - Core discovery feature
5. **KT Bottom Sheet** - Modal presentations

### Medium Priority (Phase 2 - Weeks 5-8)
6. **KT AI Navigation Bar** - AI features foundation
7. **KT AI Prompt Field** - AI interaction
8. **KT List Component** - Data presentation
9. **KT Tab Navigation** - Content organization
10. **KT Top Navigation** - Screen headers

### Lower Priority (Phase 3 - Weeks 9-12)
11. **KT Notification** - User feedback
12. **KT Popup/Dialog** - Confirmations
13. **KT Dropdown** - Selection controls
14. **KT Checkbox/Radio** - Settings
15. **KT Slider** - Range controls
16. **KT Tooltip** - Accessibility
17. **KT AI Process Indicator** - AI status
18. **KT AI Side Panel** - Contextual info
19. **KT AI Prompt Output** - AI responses
20. **KT Divider** - Content separation

---

## 4. Testing and Quality Assurance

### 4.1 Component Testing Strategy
Each component requires:
- **Widget Tests**: Rendering and interaction
- **Golden Tests**: Visual regression prevention
- **Accessibility Tests**: WCAG 2.1 compliance
- **Performance Tests**: Rendering efficiency

### 4.2 Integration Testing
- **AI Component Integration**: End-to-end AI workflows
- **Music Context Flow**: Context preservation across screens
- **Real-time Features**: Live updates and synchronization
- **Cross-platform Consistency**: iOS/Android parity

### 4.3 User Testing
- **Usability Testing**: Task completion efficiency
- **AI UX Testing**: Natural language interaction quality
- **Music Community Testing**: Domain expert feedback
- **Accessibility Testing**: Screen reader and motor accessibility

---

This comprehensive specification provides the foundation for implementing all KT UXD components with music-specific enhancements and AI integration. Each component is designed to work seamlessly within the Girls Band Tabi ecosystem while maintaining KT UXD design principles and accessibility standards.