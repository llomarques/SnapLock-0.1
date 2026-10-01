import 'package:flutter/material.dart';

class AvatarSquareWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final String? fallbackAsset;

  const AvatarSquareWidget({
    super.key,
    required this.imageUrl,
    this.size = 33,
    this.backgroundColor = const Color(0xFFD7CBBD),
    this.iconColor = const Color(0xFF5E3023),
    this.fallbackAsset,
  });

  Widget _placeholder() => fallbackAsset != null
      ? Image.asset(fallbackAsset!, fit: BoxFit.cover)
      : ColoredBox(
          color: backgroundColor,
          child: Icon(Icons.person, color: iconColor, size: size * 0.68),
        );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox.square(
        dimension: size,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
      ),
    );
  }
}
