library pro_media_editor;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

export 'src/image_editor.dart';
export 'src/video_editor.dart';

class ProMediaEditor extends StatefulWidget {
  const ProMediaEditor({super.key});

  @override
  ProMediaEditorState createState() => ProMediaEditorState();
}

class ProMediaEditorState extends State<ProMediaEditor> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isPhotoMode = true;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    print("Initializing camera...");

    if (_isCameraInitialized) {
      print("Camera already initialized.");
      return;
    }

    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0], // Choose the appropriate camera
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      _isCameraInitialized = true;
      print("Camera initialized successfully.");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isCameraInitialized
          ? Container()
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(child: CameraPreview(_controller!)),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_library,
                                    color: Colors.white, size: 40),
                                onPressed: _pickMedia,
                              ),
                              GestureDetector(
                                onTap: _captureMedia,
                                child: const CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cameraswitch,
                                    color: Colors.white, size: 40),
                                onPressed: _toggleCamera,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isPhotoMode = true;
                                  });
                                },
                                child: const Text('Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isPhotoMode ? Colors.blue : Colors.grey,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isPhotoMode = false;
                                  });
                                },
                                child: const Text('Video'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      !_isPhotoMode ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    color: Colors.black,
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white, size: 30),
                    onPressed: _toggleFlash,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller?.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _initializeCamera();
  }

  Future<void> _captureMedia() async {
    if (_isPhotoMode) {
      final image = await _controller?.takePicture();

      if (image != null) {
        final pickedFileBytes = await image.readAsBytes();
        // Navigator.push(
        //   context,
        //   // MaterialPageRoute(
        //   //   builder: (context) => ProImageEditor(
        //   //     imageBytes: pickedFileBytes,
        //   //     editedImage: (image) {},
        //   //   ),
        //   // ),
        // );
      }
    } else {
      await _controller?.startVideoRecording();
      await Future.delayed(const Duration(seconds: 5)); // Record for 5 seconds
      final video = await _controller?.stopVideoRecording();
      if (video != null) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProVideoEditor(
        //       videoPath: video.path,
        //     ),
        //   ),
        // );
      }
    }
  }

  Future<void> _pickMedia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (_isPhotoMode) {
        final pickedFileBytes = await pickedFile.readAsBytes();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return ProImageEditor(
        //         imageBytes: pickedFileBytes,
        //         editedImage: (image) {},
        //       );
        //     },
        //   ),
        // );
      } else {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProVideoEditor(
        //       videoPath: pickedFile.path,
        //     ),
        //   ),
        // );
      }
    }
  }
}
