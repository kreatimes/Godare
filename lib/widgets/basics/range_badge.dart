import 'package:flutter/material.dart';

/// Widget reutilizable que muestra el icono de rango según el nivel.
class RangeBadge extends StatelessWidget {
  final String? rangeImageUrl;
  final double size;

  const RangeBadge({super.key, required this.rangeImageUrl, this.size = 20});

  @override
  Widget build(BuildContext context) {
    if (rangeImageUrl == null) return const SizedBox.shrink();

    return Image.network(
      rangeImageUrl!,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}