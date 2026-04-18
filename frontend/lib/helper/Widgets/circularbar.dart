import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCircularLoader extends StatefulWidget {
  const VideoCircularLoader({super.key, this.loadingText = "Loading..."});
  final String loadingText;

  @override
  State<VideoCircularLoader> createState() => _VideoCircularLoaderState();
}

class _VideoCircularLoaderState extends State<VideoCircularLoader> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize video controller
    _controller =
        VideoPlayerController.asset(
            "assets/animation/circularbar.mp4", // Make sure path matches exactly
          )
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.play();

            // Ensure state updates after first frame
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        0.7,
      ), // semi-transparent overlay
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isInitialized
                ? ClipOval(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
            const SizedBox(height: 20),
            Text(
              widget.loadingText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
