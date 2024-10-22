import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_media_editor/src/image_editor_src/cropping_image.dart';
import 'package:pro_media_editor/src/image_editor_src/filters/filter_screen.dart';
import 'package:pro_media_editor/src/image_editor_src/image_sketching.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';

class ProImageEditor extends StatefulWidget {
  final Uint8List imageBytes;
  final bool addStatus;
  final Function(Uint8List, String) editedImage;

  const ProImageEditor(
      {super.key,
      required this.imageBytes,
      required this.editedImage,
      this.addStatus = true});

  @override
  ProImageEditorState createState() => ProImageEditorState();
}

class ProImageEditorState extends State<ProImageEditor> {
  List<Uint8List> history = [];
  List<Uint8List> redoStack = [];
  Uint8List _currentImage = Uint8List.fromList([]);
  CroppingImage imageCropper = CroppingImage();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageBytes;
    history.add(_currentImage);
  }

  void _undo() {
    if (history.length > 1) {
      setState(() {
        redoStack.add(_currentImage); // Save current state to redo stack
        _currentImage = history.removeLast(); // Restore last state from history
      });
    }
  }

  void _redo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        history.add(_currentImage); // Save current state to history
        _currentImage =
            redoStack.removeLast(); // Restore last state from redo stack
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

  Future<void> sketchImage() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SketchImage(
          image: _currentImage,
          onExport: (image) {
            print("image: $image");
            history.add(image);
            _currentImage = image;
            setState(() {});
          });
    }));
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
    widget.editedImage(_currentImage, textEditingController.text);
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
                  child: Column(
                    children: [
                      if (widget.addStatus)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: openStatusWriter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ProIconButton(
                              padding: const EdgeInsets.all(10),
                              onTap: cropImage,
                              icon: Icons.crop_rotate,
                            ),
                            ProIconButton(
                              padding: const EdgeInsets.all(10),
                              onTap: addFilters,
                              icon: Icons.filter,
                            ),
                            ProIconButton(
                              padding: const EdgeInsets.all(10),
                              onTap: sketchImage,
                              icon: Icons.edit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            if (textEditingController.text.isNotEmpty)
              Positioned(bottom: 80, left: 0, right: 0, child: buildStatus()),
          ],
        ),
      ),
    );
  }

  Widget buildStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Text(
        textEditingController.text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
