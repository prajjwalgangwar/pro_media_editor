import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pro_media_editor/src/video_editor_src/pro_video_player.dart';
import 'package:pro_media_editor/src/video_editor_src/video_trimmer_view.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';
import 'package:video_player/video_player.dart';

class ProVideoEditor extends StatefulWidget {
  final String videoPath;
  final bool canAddStatus;
  final Function(String, int, String) onSave;
  const ProVideoEditor({
    super.key,
    required this.videoPath,
    required this.onSave,
    this.canAddStatus = true,
  });

  @override
  State<ProVideoEditor> createState() => _ProVideoEditorState();
}

class _ProVideoEditorState extends State<ProVideoEditor> {
  late VideoPlayerController _videoPlayerController;
  // List<String> history = List.empty(growable: true);
  String currentVideoPath = '';
  bool _isInitialized = false;
  bool _isTrimming = false;
  int videoDurationInMillis = 0;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  updateEditedPath(String path) {
    currentVideoPath = path;
    _videoPlayerController.dispose();
    _videoPlayerController = VideoPlayerController.file(File(path));
    _videoPlayerController.initialize().then((_) {
      setState(() {
        _isInitialized = true;
        videoDurationInMillis =
            _videoPlayerController.value.duration.inMilliseconds;
      });
    });
    setState(() {});
  }

  // void _undo() {
  //   if (history.length > 1) {
  //     setState(() {
  //       final videoPath = history.last;
  //       _videoPlayerController.dispose();
  //       _videoPlayerController = VideoPlayerController.file(File(videoPath));
  //       _videoPlayerController.initialize().then((_) {
  //         setState(() {
  //           _isInitialized = true;
  //         });
  //       });
  //     });
  //   }
  // }

  // void _redo() {
  //   setState(() {
  //     final videoPath = history.last;
  //     _videoPlayerController.dispose();
  //     _videoPlayerController = VideoPlayerController.file(File(videoPath));
  //     _videoPlayerController.initialize().then((_) {
  //       setState(() {
  //         _isInitialized = true;
  //       });
  //     });
  //   });
  // }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(
      File(widget.videoPath),
    );
    await _videoPlayerController.initialize();
    setState(() {
      _isInitialized = true;
      currentVideoPath = widget.videoPath;
      videoDurationInMillis =
          _videoPlayerController.value.duration.inMilliseconds;
    });
  }

  _saveVideo() {
    widget.onSave(
        currentVideoPath, videoDurationInMillis, textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Editor'),
        actions: [
          ProIconButton(
            onTap: _saveVideo,
            icon: Icons.check,
            padding: const EdgeInsets.all(6),
          )
        ],
      ),
      body: Stack(
        children: [
          // Centered video player
          Align(
            alignment: Alignment.center,
            child: _isInitialized
                ? VideoPlayerWidget(
                    controller: _videoPlayerController,
                    status: textEditingController.text,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // Top container for icon buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: buildTop(),
          ),
          // Bottom container for icon buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildBottom(),
          ),
        ],
      ),
    );
  }

  Widget buildBottom() {
    return Container(
      // height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          if (widget.canAddStatus)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: openStatusWriter,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      "Add Status",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ProIconButton(
                  padding: EdgeInsets.all(8),
                  onTap: () {
                    if (!_isTrimming) {
                      _trimVideo();
                    }
                  },
                  icon: Icons.cut_outlined,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTop() {
    return Container(
        // height: 80, // Adjust height as needed
        // color: Colors.black.withOpacity(0.5), // Semi-transparent background
        // child: const Center(
        //   child: Text('Top Container'), // Placeholder for icons
        // ),
        );
  }

  openStatusWriter() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return AlertDialog(
            title: const Text("Status"),
            content: TextFormField(
              controller: textEditingController,
              style: Theme.of(context).textTheme.labelMedium,
              decoration: const InputDecoration(
                  hintText: "Status",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
            ),
            actions: [
              ProIconButton(
                backgroundColor: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                },
                icon: Icons.close,
                iconColor: Colors.white,
              ),
              ProIconButton(
                backgroundColor: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                icon: Icons.check,
                iconColor: Colors.white,
              )
            ],
          );
        });
  }

  Future<void> _trimVideo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoTrimmerView(
          videoPath: currentVideoPath,
          onTrimmed: (value) {
            updateEditedPath(value);
          },
        ),
      ),
    );

    // Handle the result if necessary
    // if (result != null) {
    // Process the result
    // }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
