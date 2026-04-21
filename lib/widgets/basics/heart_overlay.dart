import 'package:flutter/material.dart';

// Overlay animado de corazón al hacer doble tap sobre el contenido.
/// Envuelve cualquier widget y ejecuta [onDoubleTap] además de la animación.
class HeartOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDoubleTap;

  const HeartOverlay({
    super.key,
    required this.child,
    this.onDoubleTap,
  });

  @override
  State<HeartOverlay> createState() => _HeartOverlayState();
}

class _HeartOverlayState extends State<HeartOverlay> {
  bool _showHeart = false;

  void _handleDoubleTap() {
    widget.onDoubleTap?.call();
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedOpacity(
            opacity: _showHeart ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: _showHeart ? 1.2 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 90,
                shadows: [Shadow(color: Colors.black38, blurRadius: 20)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
