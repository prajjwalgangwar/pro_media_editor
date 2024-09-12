import 'package:flutter/material.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final String status;

  const VideoPlayerWidget(
      {super.key, required this.controller, this.status = ''});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(widget.controller),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Center(
                  child: ProIconButton(
                    onTap: toggleVideo,
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
              ),
              Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: _buildVideoProgressBarWithTiming()),
              if (widget.status.isNotEmpty)
                Positioned(bottom: 80, left: 0, right: 0, child: buildStatus()),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: Colors.black26),
      child: Text(
        widget.status,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVideoProgressBarWithTiming() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // Current position of the video
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, VideoPlayerValue value, child) {
              return Text(
                _formatDuration(value.position),
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
          // Progress bar
          Expanded(
            child: VideoProgressIndicator(
              widget.controller,
              allowScrubbing:
                  true, // Allow seeking by tapping/dragging on the progress bar
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              colors: const VideoProgressColors(
                playedColor: Colors.white, // Color of the played portion
                backgroundColor:
                    Colors.black26, // Background color of the progress bar
                bufferedColor: Colors.black, // Buffered portion
              ),
            ),
          ),
          // Total duration of the video
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, VideoPlayerValue value, child) {
              return Text(
                _formatDuration(value.duration),
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void toggleVideo() {
    setState(() {
      if (isPlaying) {
        _pause();
      } else {
        _play();
      }
      // Toggle the isPlaying state
      isPlaying = !isPlaying;
    });
  }

  void _play() {
    widget.controller.play();
  }

  void _pause() {
    widget.controller.pause();
  }
}
