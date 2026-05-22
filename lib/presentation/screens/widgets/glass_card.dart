import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/screens/widgets/hatched_painter.dart';
import 'package:aulos/presentation/screens/widgets/ceramic_painter.dart';
import 'package:provider/provider.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? blur;
  final double? opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool fullHeight;

  const GlassCard({
    super.key,
    required this.child,
    this.title,
    this.blur,
    this.opacity,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius,
    this.fullHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsVM = context.watch<SettingsViewModel>();
    final playerVM = context.watch<PlayerViewModel>();
    final model = settingsVM.themeModel;

    final String themeStyle = _getStyleFromName(model.name);
    final bool isDynamic = settingsVM.isDynamicTheme;

    Color primaryColor = theme.colorScheme.primary;
    if (isDynamic && playerVM.extractedColor != null) {
      primaryColor = playerVM.extractedColor!;
    }

    final double themeBlur = _getBlurForStyle(themeStyle);
    final double themeOpacity = _getOpacityForStyle(themeStyle);
    final double themeRoundness = model.effects?.roundness ?? 28.0;

    final effectiveBlur = blur ?? themeBlur;
    final effectiveOpacity = opacity ?? themeOpacity;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(themeRoundness);

    final Widget innerContent = Column(
      mainAxisSize: fullHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (fullHeight) Expanded(child: child) else child,
      ],
    );

    final Widget decorationLayer = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: (themeStyle == 'ceramic' || themeStyle == 'flat')
            ? theme.colorScheme.surface
            : theme.colorScheme.onSurface.withValues(alpha: effectiveOpacity),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: isDynamic
              ? primaryColor.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: themeStyle == 'hatched' ? 2.0 : 1.5,
        ),
        boxShadow: themeStyle == 'ceramic' || themeStyle == 'flat'
            ? [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: themeStyle == 'flat' ? 0.05 : 0.15,
                  ),
                  blurRadius: themeStyle == 'flat' ? 4 : 15,
                  offset: Offset(0, themeStyle == 'flat' ? 2 : 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (themeStyle == 'hatched')
            Positioned.fill(
              child: CustomPaint(
                painter: HatchedPainter(
                  color: isDynamic ? primaryColor : theme.colorScheme.onSurface,
                ),
              ),
            ),
          if (themeStyle == 'ceramic')
            Positioned.fill(
              child: CustomPaint(
                painter: CeramicPainter(
                  color: theme.colorScheme.primary,
                ), // Traditional Blue
              ),
            ),
          innerContent,
        ],
      ),
    );

    if (effectiveBlur > 0) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: decorationLayer,
        ),
      );
    }

    return decorationLayer;
  }

  String _getStyleFromName(String name) {
    if (name.contains('Origami')) return 'flat';
    if (name.contains('Hatched')) return 'hatched';
    if (name.contains('Ceramic')) return 'ceramic';
    return 'glass';
  }

  double _getBlurForStyle(String style) {
    if (style == 'glass') return 20.0;
    return 0.0;
  }

  double _getOpacityForStyle(String style) {
    if (style == 'flat' || style == 'ceramic') return 1.0;
    if (style == 'hatched') return 0.05;
    return 0.1;
  }
}
