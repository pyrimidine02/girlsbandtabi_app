/// EN: Optimized network image widget with shimmer and accessibility.
/// KO: 쉬머와 접근성을 포함한 최적화 네트워크 이미지 위젯.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../utils/media_url.dart';
import '../feedback/gbt_loading.dart';

/// EN: Optimized image widget for remote URLs.
/// KO: 원격 URL을 위한 최적화 이미지 위젯.
class GBTImage extends StatelessWidget {
  const GBTImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.borderRadius,
    this.useShimmer = true,
    this.placeholder,
    this.errorWidget,
  });

  /// EN: Image URL.
  /// KO: 이미지 URL.
  final String imageUrl;

  /// EN: Image width.
  /// KO: 이미지 너비.
  final double? width;

  /// EN: Image height.
  /// KO: 이미지 높이.
  final double? height;

  /// EN: Image fit behavior.
  /// KO: 이미지 맞춤 방식.
  final BoxFit fit;

  /// EN: Semantic label for accessibility.
  /// KO: 접근성 시맨틱 라벨.
  final String? semanticLabel;

  /// EN: Optional border radius for clipping.
  /// KO: 클리핑을 위한 모서리 반경.
  final BorderRadius? borderRadius;

  /// EN: Whether to show shimmer placeholder.
  /// KO: 쉬머 플레이스홀더 표시 여부.
  final bool useShimmer;

  /// EN: Custom placeholder widget.
  /// KO: 커스텀 플레이스홀더 위젯.
  final Widget? placeholder;

  /// EN: Custom error widget.
  /// KO: 커스텀 에러 위젯.
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveMediaUrl(imageUrl);
    final baseImage = CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      placeholder: (context, _) => _buildPlaceholder(),
      errorWidget: (context, _, __) => _buildError(),
      imageBuilder: (context, imageProvider) {
        return Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );

    final image = semanticLabel != null
        ? Semantics(label: semanticLabel, image: true, child: baseImage)
        : baseImage;

    final resolvedBorderRadius = borderRadius;
    if (resolvedBorderRadius == null) return image;

    return ClipRRect(borderRadius: resolvedBorderRadius, child: image);
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    final container = Container(
      width: width,
      height: height,
      color: GBTColors.surfaceVariant,
    );

    if (!useShimmer) return container;

    return GBTShimmer(child: container);
  }

  Widget _buildError() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GBTColors.surfaceVariant,
        borderRadius:
            borderRadius ?? BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Icon(
        Icons.broken_image,
        color: GBTColors.textTertiary,
        size: GBTSpacing.iconLg,
      ),
    );
  }
}
