import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ImageFilterScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onImageConfirmed;

  const ImageFilterScreen({
    Key? key,
    required this.imageBytes,
    required this.onImageConfirmed,
  }) : super(key: key);

  @override
  State<ImageFilterScreen> createState() => _ImageFilterScreenState();
}

class _ImageFilterScreenState extends State<ImageFilterScreen> {
  Uint8List? _filteredImage;
  bool _isProcessing = false;

  final List<Color> _filters = [
    Colors.transparent,
    Colors.red.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
    Colors.yellow.withOpacity(0.5),
    Colors.purple.withOpacity(0.5),
  ];

  Color _customColor = Colors.transparent;
  Color _previewColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _filteredImage = widget.imageBytes;
  }

  Future<void> _applyFilter(Color filterColor) async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 10)); // Avoid UI freezing
    final Uint8List processedImage =
        await _processImage(widget.imageBytes, filterColor);

    setState(() {
      _filteredImage = processedImage;
      _isProcessing = false;
    });
  }

  Future<Uint8List> _processImage(
      Uint8List imageBytes, Color filterColor) async {
    final ui.Image originalImage = await _loadImage(imageBytes);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(),
          originalImage.height.toDouble()),
    );

    // Draw original image
    canvas.drawImage(originalImage, Offset.zero, Paint());

    // Apply filter
    if (filterColor != Colors.transparent) {
      final paint = Paint()
        ..color = filterColor
        ..blendMode = BlendMode.color;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, originalImage.width.toDouble(),
            originalImage.height.toDouble()),
        paint,
      );
    }

    final picture = recorder.endRecording();
    final filteredImage = await picture.toImage(
      originalImage.width,
      originalImage.height,
    );

    final byteData =
        await filteredImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> _loadImage(Uint8List imageBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, completer.complete);
    return completer.future;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Custom Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _customColor,
              onColorChanged: (color) {
                setState(() {
                  _previewColor = color.withOpacity(0.5);
                  _customColor = color.withOpacity(0.5);
                });
              },
              enableAlpha: true,
              showLabel: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _previewColor = _customColor;
                });
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_filteredImage != null) {
                // Process the final image with the chosen color
                _applyFilter(_previewColor).then((_) {
                  widget.onImageConfirmed(_filteredImage!);
                  Navigator.pop(context);
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _previewColor,
                    BlendMode.color,
                  ),
                  child: Image.memory(
                    widget.imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
                if (_isProcessing)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          if (!_isProcessing)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._filters.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _previewColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.palette,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
