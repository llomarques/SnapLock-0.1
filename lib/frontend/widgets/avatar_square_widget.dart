import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_theme.dart';

class AvatarSquareWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? fallbackAsset;

  const AvatarSquareWidget({
    super.key,
    required this.imageUrl,
    this.size = 33,
    this.backgroundColor,
    this.iconColor,
    this.fallbackAsset,
  });

  Widget _placeholder(BuildContext context) => fallbackAsset != null
      ? Image.asset(fallbackAsset!, fit: BoxFit.cover)
      : ColoredBox(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.person,
            color: iconColor ?? AppTheme.darkBrown,
            size: size * 0.68,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox.square(
        dimension: size,
        child: imageUrl.isEmpty
            ? _placeholder(context)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(context),
              ),
      ),
    );
  }
}
