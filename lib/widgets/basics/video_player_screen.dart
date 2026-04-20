import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../values/colors_app.dart';

/// Reproductor de vídeo para posts de tipo DARE.
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      if (!mounted) return;

      // Detectar cuando el vídeo llega al final
      _controller.addListener(_onVideoProgress);

      setState(() => _isInitialized = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _onVideoProgress() {
    if (!mounted) return;
    final value = _controller.value;
    final finished =
        value.duration > Duration.zero && value.position >= value.duration;
    if (finished != _isFinished) {
      setState(() => _isFinished = finished);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isFinished) {
      // Reiniciar y reproducir desde el principio
      _controller.seekTo(Duration.zero);
      _controller.play();
      setState(() => _isFinished = false);
    } else {
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
    }
  }

  Future<void> _openFullscreen() async {
    if (_controller.value.isPlaying) _controller.pause();

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullscreenVideoPage(videoUrl: widget.videoUrl),
    ));

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 400,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 48),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 400,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        children: [
          // Vídeo tappable para play/pause/replay
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlay,
              child: ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlay central de replay cuando el vídeo acaba
          if (_isFinished)
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                  child: const Icon(
                    Icons.replay,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          // Controles en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),

          // Botón de pantalla completa — esquina superior derecha
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openFullscreen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _isFinished
                  ? Icons.replay
                  : (_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
              size: 32,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: _VideoProgressBar(controller: _controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _VideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final int total = value.duration.inMilliseconds;
        final double played =
        total > 0 ? (value.position.inMilliseconds / total).clamp(0.0, 1.0) : 0.0;
        final double buffered = total > 0 && value.buffered.isNotEmpty
            ? (value.buffered.last.end.inMilliseconds / total).clamp(0.0, 1.0)
            : 0.0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _seek(d.localPosition.dx, w, total),
              onHorizontalDragUpdate: (d) => _seek(d.localPosition.dx, w, total),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Stack(
                  children: [
                    Container(height: 3, width: w, color: Colors.white24),
                    Container(height: 3, width: buffered * w, color: Colors.white54),
                    Container(height: 3, width: played * w, color: ColorsApp.basePink),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _seek(double dx, double totalWidth, int totalMs) {
    if (totalMs == 0 || totalWidth == 0) return;
    final fraction = (dx / totalWidth).clamp(0.0, 1.0);
    controller.seekTo(Duration(milliseconds: (fraction * totalMs).round()));
  }
}

// ---------------------------------------------------------------------------
// Pantalla completa de vídeo
// ---------------------------------------------------------------------------

class _FullscreenVideoPage extends StatefulWidget {
  final String videoUrl;

  const _FullscreenVideoPage({required this.videoUrl});

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      if (!mounted) return;

      _controller.addListener(_onVideoProgress);

      setState(() => _isInitialized = true);
      _controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _onVideoProgress() {
    if (!mounted) return;
    final value = _controller.value;
    final finished =
        value.duration > Duration.zero && value.position >= value.duration;
    if (finished != _isFinished) {
      setState(() => _isFinished = finished);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlay() {
    if (_isFinished) {
      _controller.seekTo(Duration.zero);
      _controller.play();
      setState(() => _isFinished = false);
    } else {
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vídeo tappable
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlay,
              child: Center(
                child: _hasError
                    ? const Icon(Icons.error_outline,
                    color: Colors.white, size: 64)
                    : !_isInitialized
                    ? const CircularProgressIndicator()
                    : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),

          // Overlay central de replay cuando el vídeo acaba
          if (_isFinished && _isInitialized)
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                  child: const Icon(
                    Icons.replay,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),

          // Controles en la parte inferior
          if (_isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFinished
                            ? Icons.replay
                            : (_controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: _togglePlay,
                    ),
                    Expanded(
                      child: _VideoProgressBar(controller: _controller),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

          // Botón de cerrar — esquina superior izquierda
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}