import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FlowGradientBackground extends StatelessWidget {
  const FlowGradientBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.heroLayer = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool heroLayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvasColors = isDark
        ? AppColors.darkCanvasGradient
        : AppColors.lightCanvasGradient;
    final heroColors = isDark
        ? AppColors.darkHeroGradient
        : AppColors.lightHeroGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canvasColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: heroLayer ? -120 : -160,
            left: -120,
            child: _GradientBlob(
              colors: heroColors,
              size: heroLayer ? 320 : 260,
              opacity: heroLayer ? 0.32 : 0.22,
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _GradientBlob(
              colors: heroColors.reversed.toList(),
              size: heroLayer ? 300 : 240,
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: heroLayer ? 80 : 60,
            right: -160,
            child: _GradientBlob(
              colors: [
                heroColors.first.withValues(alpha: 0.32),
                Colors.transparent,
              ],
              size: heroLayer ? 360 : 280,
              opacity: 0.12,
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({
    required this.colors,
    required this.size,
    required this.opacity,
  });

  final List<Color> colors;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors
                .map((color) => color.withValues(alpha: opacity))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class FlowCard extends StatelessWidget {
  const FlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.gradient,
    this.borderRadius = 24,
    this.blurSigma = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = gradient ??
        LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkSurface.withValues(alpha: 0.78),
                  AppColors.darkSurfaceElevated.withValues(alpha: 0.92),
                ]
              : [
                  AppColors.lightSurface.withValues(alpha: 0.85),
                  AppColors.lightSurfaceElevated.withValues(alpha: 0.95),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final borderColor = isDark
        ? AppColors.darkCardOutline
        : AppColors.lightCardOutline;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class FlowSectionHeader extends StatelessWidget {
  const FlowSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class FlowMetricTile extends StatelessWidget {
  const FlowMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return FlowCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              if (icon != null) const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class FlowPill extends StatelessWidget {
  const FlowPill({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.onTap,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = backgroundColor ??
        theme.colorScheme.secondary.withValues(alpha: 0.12);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
