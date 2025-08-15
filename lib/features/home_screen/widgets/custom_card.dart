import 'package:flutter/material.dart';

// Enum for different card styles
enum CardStyle { classic, modern, minimal, bold, soft, neon, dark, custom }

// Configuration class for card styling
class CardStyleConfig {
  final BorderRadius borderRadius;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final TileMode tileMode;
  final TextStyle textStyle;
  final double imageOpacity;
  final double imageSize;
  final EdgeInsets padding;
  final List<BoxShadow>? boxShadow;

  const CardStyleConfig({
    required this.borderRadius,
    required this.gradientColors,
    required this.gradientStops,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.tileMode,
    required this.textStyle,
    required this.imageOpacity,
    required this.imageSize,
    required this.padding,
    this.boxShadow,
  });
}

class CustomCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? imagePath;
  final IconData? icon;
  final CardStyle style;
  final CardStyleConfig? customConfig;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.label,
    this.onTap,
    this.imagePath,
    this.icon,
    this.style = CardStyle.classic,
    this.customConfig,
    this.width,
    this.height,
  });

  // Get style configuration based on enum
  CardStyleConfig _getStyleConfig() {
    if (style == CardStyle.custom && customConfig != null) {
      return customConfig!;
    }

    switch (style) {
      case CardStyle.classic:
        return const CardStyleConfig(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
          gradientStops: [0.4, 0.7],
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
          tileMode: TileMode.repeated,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.white, offset: Offset(0.5, 0.75))],
          ),
          imageOpacity: 0.5,
          imageSize: 50,
          padding: EdgeInsets.all(16),
        );

      case CardStyle.modern:
        return CardStyleConfig(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
          gradientStops: const [0.0, 1.0],
          gradientBegin: Alignment.topLeft,
          gradientEnd: Alignment.bottomRight,
          tileMode: TileMode.clamp,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          imageOpacity: 0.8,
          imageSize: 40,
          padding: const EdgeInsets.all(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CardStyle.minimal:
        return const CardStyleConfig(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          gradientColors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
          gradientStops: [0.0, 1.0],
          gradientBegin: Alignment.topCenter,
          gradientEnd: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
          imageOpacity: 0.7,
          imageSize: 32,
          padding: EdgeInsets.all(16),
        );

      case CardStyle.bold:
        return CardStyleConfig(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          gradientColors: const [Color(0xFFff6b6b), Color(0xFFfeca57)],
          gradientStops: const [0.0, 1.0],
          gradientBegin: Alignment.centerLeft,
          gradientEnd: Alignment.centerRight,
          tileMode: TileMode.clamp,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
          ),
          imageOpacity: 0.9,
          imageSize: 60,
          padding: const EdgeInsets.all(24),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case CardStyle.soft:
        return CardStyleConfig(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          gradientColors: [Colors.pink.shade100, Colors.purple.shade100],
          gradientStops: const [0.0, 1.0],
          gradientBegin: Alignment.topLeft,
          gradientEnd: Alignment.bottomRight,
          tileMode: TileMode.clamp,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          imageOpacity: 0.6,
          imageSize: 45,
          padding: const EdgeInsets.all(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );

      case CardStyle.neon:
        return CardStyleConfig(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          gradientColors: const [Color(0xFF0f3460), Color(0xFF16537e)],
          gradientStops: const [0.0, 1.0],
          gradientBegin: Alignment.topLeft,
          gradientEnd: Alignment.bottomRight,
          tileMode: TileMode.clamp,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00d4ff),
            shadows: [Shadow(color: Color(0xFF00d4ff), blurRadius: 10)],
          ),
          imageOpacity: 1.0,
          imageSize: 48,
          padding: const EdgeInsets.all(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00d4ff).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        );

      case CardStyle.dark:
        return CardStyleConfig(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          gradientColors: const [Color(0xFF2c2c2c), Color(0xFF1a1a1a)],
          gradientStops: const [0.0, 1.0],
          gradientBegin: Alignment.topCenter,
          gradientEnd: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
          imageOpacity: 0.8,
          imageSize: 50,
          padding: const EdgeInsets.all(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );

      case CardStyle.custom:
        // Fallback to classic if custom config is not provided
        return _getStyleConfigForStyle(CardStyle.classic);
    }
  }

  CardStyleConfig _getStyleConfigForStyle(CardStyle targetStyle) {
    final tempCard = CustomCard(label: '', style: targetStyle);
    return tempCard._getStyleConfig();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStyleConfig();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: config.padding,
        decoration: BoxDecoration(
          borderRadius: config.borderRadius,
          gradient: LinearGradient(
            colors: config.gradientColors,
            begin: config.gradientBegin,
            end: config.gradientEnd,
            stops: config.gradientStops,
            tileMode: config.tileMode,
          ),
          boxShadow: config.boxShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                height: config.imageSize,
                width: config.imageSize,
                opacity: AlwaysStoppedAnimation<double>(config.imageOpacity),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: config.imageSize,
                    color: Colors.white.withOpacity(config.imageOpacity),
                  );
                },
              ),
              const SizedBox(height: 12),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: config.imageSize,
                color: config.textStyle.color?.withOpacity(config.imageOpacity),
              ),
              const SizedBox(height: 12),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: config.textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for easy custom style creation
extension CustomCardStyle on CustomCard {
  static CardStyleConfig createCustomStyle({
    BorderRadius? borderRadius,
    List<Color>? gradientColors,
    List<double>? gradientStops,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
    TileMode? tileMode,
    TextStyle? textStyle,
    double? imageOpacity,
    double? imageSize,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
  }) {
    return CardStyleConfig(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(20)),
      gradientColors:
          gradientColors ?? [const Color(0xFF667eea), const Color(0xFF764ba2)],
      gradientStops: gradientStops ?? [0.0, 1.0],
      gradientBegin: gradientBegin ?? Alignment.bottomLeft,
      gradientEnd: gradientEnd ?? Alignment.topRight,
      tileMode: tileMode ?? TileMode.clamp,
      textStyle:
          textStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
      imageOpacity: imageOpacity ?? 0.5,
      imageSize: imageSize ?? 50,
      padding: padding ?? const EdgeInsets.all(16),
      boxShadow: boxShadow,
    );
  }
}
