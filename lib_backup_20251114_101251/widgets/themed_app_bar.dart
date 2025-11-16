import 'package:flutter/material.dart';
import 'dart:ui';

/// A custom SliverAppBar that mimics the large-to-small title transition
/// seen in native iOS apps, as specified in the planning document (1.3.2).
///
/// It uses a transparent background with a blur effect to achieve the
/// 'Liquid Glass' style.
class ThemedAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const ThemedAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 120.0,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            centerTitle: true,
            title: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 17),
            ),
            background: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 40),
                child: Text(
                  title,
                  style: theme.textTheme.displayLarge,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }
}
