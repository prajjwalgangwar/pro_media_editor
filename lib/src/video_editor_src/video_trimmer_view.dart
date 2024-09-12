import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerView extends StatefulWidget {
  final String videoPath;
  final Function(String) onTrimmed;
  const VideoTrimmerView(
      {super.key, required this.videoPath, required this.onTrimmed});

  @override
  State<VideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<VideoTrimmerView> {
  final _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() => _trimmer.loadVideo(videoFile: File(widget.videoPath));

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        if (outputPath != null) {
          widget.onTrimmed(outputPath);
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress) {
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Video Trimmer'),
            actions: [
              ProIconButton(
                onTap: () {
                  if (_progressVisibility) {
                    return null;
                  } else {
                    _saveVideo().then(
                      (outputPath) {
                        debugPrint('OUTPUT PATH: $outputPath');
                        const snackBar = SnackBar(
                          content: Text('Video Saved successfully'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    );
                  }
                },
                icon: Icons.check,
              )
            ],
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Visibility(
                    visible: _progressVisibility,
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  Expanded(child: VideoViewer(trimmer: _trimmer)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TrimViewer(
                        trimmer: _trimmer,
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        durationStyle: DurationStyle.FORMAT_MM_SS,
                        maxVideoLength: Duration(
                          seconds: _trimmer
                              .videoPlayerController!.value.duration.inSeconds,
                        ),
                        editorProperties: TrimEditorProperties(
                          borderPaintColor: Colors.yellow,
                          borderWidth: 4,
                          borderRadius: 5,
                          circlePaintColor: Colors.yellow.shade800,
                        ),
                        areaProperties:
                            TrimAreaProperties.edgeBlur(thumbnailQuality: 10),
                        onChangeStart: (value) => _startValue = value,
                        onChangeEnd: (value) => _endValue = value,
                        onChangePlaybackState: (value) => setState(
                          () => _isPlaying = value,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: _isPlaying
                        ? const Icon(
                            Icons.pause,
                            size: 80.0,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.play_arrow,
                            size: 80.0,
                            color: Colors.white,
                          ),
                    onPressed: () async {
                      final playbackState = await _trimmer.videoPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      setState(() => _isPlaying = playbackState);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
