import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class LocalVideoCard extends StatefulWidget {
  final String assetPath;
  final String title;

  const LocalVideoCard({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<LocalVideoCard> createState() => _LocalVideoCardState();
}

class _LocalVideoCardState extends State<LocalVideoCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(.06),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // 🎥 VIDEO
            if (_initialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),

            // 🌑 GLASS OVERLAY
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _controller.value.isPlaying ? 0 : 4,
                  sigmaY: _controller.value.isPlaying ? 0 : 4,
                ),
                child: Container(
                  color: Colors.black.withOpacity(
                    _controller.value.isPlaying ? 0.2 : 0.45,
                  ),
                ),
              ),
            ),

            // ▶ PLAY BUTTON
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.black54],
                    ),
                  ),
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),

            // 📄 TITLE
            Positioned(
              left: 18,
              bottom: 18,
              right: 18,
              child: Text(
                widget.title,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
