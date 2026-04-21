import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Pantalla de imagen a pantalla completa con zoom (pinch-to-zoom).
class FullscreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      // SafeArea con minimum asegura que en landscape también se respetan
      // los márgenes laterales del notch y los botones del sistema
      body: SafeArea(
        minimum: EdgeInsets.only(
          left: padding.left,
          right: padding.right,
        ),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.0,
            ),
            Positioned(
              top: 12,
              left: padding.left + 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}