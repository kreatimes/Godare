import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Pantalla de imagen a pantalla completa con zoom (pinch-to-zoom).
/// Usa el paquete photo_view para soporte de zoom y pan.
class FullscreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
              left: 12,
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