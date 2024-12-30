import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';

class SketchImage extends StatefulWidget {
  final Uint8List image;
  final Function(Uint8List) onExport;
  const SketchImage({super.key, required this.image, required this.onExport});

  @override
  State<SketchImage> createState() => _SketchImageState();
}

class _SketchImageState extends State<SketchImage> {
  final imagePainterController = ImagePainterController();
  bool exporting = false;

  onExport() async {
    exporting = true;
    setState(() {});
    Uint8List? updatedImage = await imagePainterController.exportImage();
    if (updatedImage != null) {
      widget.onExport(updatedImage);
    }
    setState(() {
      exporting = false;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    imagePainterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ImagePainter.memory(
              widget.image,
              controller: imagePainterController,
              controlsAtTop: false,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ProIconButton(
                      padding: const EdgeInsets.all(10),
                      onTap: onExport,
                      icon: Icons.check,
                    ),
                  ],
                ),
              ),
            ),
            if (exporting)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
          ],
        ),
      ),
    );
  }
}
