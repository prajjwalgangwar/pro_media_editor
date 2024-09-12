import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pro_media_editor/src/image_editor_src/cropping_image.dart';
import 'package:pro_media_editor/src/image_editor_src/filters/filter_screen.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';

class ProImageEditor extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) editedImage;

  const ProImageEditor(
      {super.key, required this.imageBytes, required this.editedImage});

  @override
  ProImageEditorState createState() => ProImageEditorState();
}

class ProImageEditorState extends State<ProImageEditor> {
  List<Uint8List> history = [];
  List<Uint8List> redoStack = [];
  late img.Image _decodedImage;
  Uint8List _currentImage = Uint8List.fromList([]);
  CroppingImage imageCropper = CroppingImage();

  @override
  void initState() {
    super.initState();
    _decodedImage = img.decodeImage(widget.imageBytes)!;
    _currentImage = widget.imageBytes;
    history.add(_currentImage);
  }

  void _undo() {
    if (history.length > 1) {
      setState(() {
        redoStack.add(_currentImage); // Save current state to redo stack
        _currentImage = history.removeLast(); // Restore last state from history
        _decodedImage = img.decodeImage(_currentImage)!;
      });
    }
  }

  void _redo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        history.add(_currentImage); // Save current state to history
        _currentImage =
            redoStack.removeLast(); // Restore last state from redo stack
        _decodedImage = img.decodeImage(_currentImage)!;
      });
    }
  }

  Future<void> cropImage() async {
    Uint8List? croppedImage =
        await imageCropper.crop(imageBytes: _currentImage);
    history.add(croppedImage);
    _currentImage = croppedImage;
    setState(() {});
  }

  Future<void> addFilters() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageFilterScreen(
          imageBytes: _currentImage,
          onImageConfirmed: (image) {
            print("image: $image");
            history.add(image);
            _currentImage = image;
            setState(() {});
          });
    }));
  }

  onBackClick() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Do you want to exit? ",
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProIconButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    icon: Icons.close,
                  ),
                  ProIconButton(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: Icons.check,
                  ),
                ],
              )
            ],
          );
        });
  }

  onImageEditComplete() {
    widget.editedImage(_currentImage);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Image.memory(history.last, fit: BoxFit.cover),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: Colors.black26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProIconButton(
                      padding: const EdgeInsets.all(8),
                      onTap: onBackClick,
                      icon: Icons.arrow_back,
                    ),
                    Row(
                      children: [
                        ProIconButton(
                          padding: const EdgeInsets.all(8),
                          onTap: _undo,
                          icon: Icons.undo,
                        ),
                        ProIconButton(
                          padding: const EdgeInsets.all(8),
                          onTap: _redo,
                          icon: Icons.redo,
                        ),
                        ProIconButton(
                          padding: const EdgeInsets.all(8),
                          onTap: onImageEditComplete,
                          icon: Icons.check,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(color: Colors.black26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProIconButton(
                        onTap: cropImage,
                        icon: Icons.crop_rotate,
                      ),
                      ProIconButton(
                        onTap: addFilters,
                        icon: Icons.filter,
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
