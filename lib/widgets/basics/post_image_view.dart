import 'package:flutter/material.dart';
import 'package:godare/widgets/basics/fullscreen_image_view.dart';
import 'package:godare/widgets/basics/heart_overlay.dart';

// Widget que muestra la imagen de un post con:
/// - Aspect ratio automático según la imagen real
/// - Doble tap → like (HeartOverlay con animación de corazón)
/// - Tap simple → pantalla completa con zoom (FullscreenImageView)
class PostImageView extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onDoubleTap;

  const PostImageView({
    super.key,
    required this.imageUrl,
    this.onDoubleTap,
  });

  @override
  State<PostImageView> createState() => _PostImageViewState();
}

class _PostImageViewState extends State<PostImageView> {
  double? _aspectRatio;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _loadImageRatio();
  }

  void _loadImageRatio() {
    final imageProvider = NetworkImage(widget.imageUrl);
    final stream = imageProvider.resolve(const ImageConfiguration());

    _listener = ImageStreamListener((ImageInfo info, bool _) {
      final width = info.image.width.toDouble();
      final height = info.image.height.toDouble();
      if (!mounted) return;
      setState(() => _aspectRatio = width / height);
    });

    stream.addListener(_listener!);
    _imageStream = stream;
  }

  @override
  void dispose() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageView(imageUrl: widget.imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      return Container(
        width: double.infinity,
        height: 220,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return HeartOverlay(
      onDoubleTap: widget.onDoubleTap,
      child: GestureDetector(
        onTap: _openFullscreen,
        child: AspectRatio(
          aspectRatio: _aspectRatio!,
          child: Image.network(
            widget.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
