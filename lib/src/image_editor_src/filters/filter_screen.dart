import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pro_media_editor/src/image_editor_src/filters/filter_selector.dart';
import 'package:pro_media_editor/src/widgets/pro_icon_button.dart';

class ImageFilterScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onImageConfirmed;

  const ImageFilterScreen({
    super.key,
    required this.imageBytes,
    required this.onImageConfirmed,
  });

  @override
  ImageFilterScreenState createState() => ImageFilterScreenState();
}

class ImageFilterScreenState extends State<ImageFilterScreen> {
  late Uint8List _originalImage;
  Uint8List? _filteredImage;
  bool _isProcessing = false;
  bool _isSaving = false; // Add a variable to track saving state

  @override
  void initState() {
    super.initState();
    _originalImage = widget.imageBytes;
    _filteredImage = widget.imageBytes;
  }

  final _filters = [
    Colors.white,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index * 4) % Colors.primaries.length],
    )
  ];

  final _filterColor = ValueNotifier<Color>(Colors.white);

  // Handle the image confirmation
  void _confirmImage() async {
    if (_filteredImage != null) {
      setState(() {
        _isSaving = true;
      });

      widget.onImageConfirmed(_filteredImage!);

      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Handle the filter application logic
  Future<void> _onFilterChanged(Color value) async {
    _filterColor.value = value;
    setState(() {
      _isProcessing = true;
    });

    await _applyFilter(value);

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _applyFilter(Color filterColor) async {
    if (!mounted) return;

    final ui.Image image = await _loadImage(Uint8List.fromList(_originalImage));

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0, 0),
        Offset(image.width.toDouble(), image.height.toDouble()),
      ),
    );

    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..color = filterColor.withOpacity(0.5)
      ..blendMode = BlendMode.color;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    final filteredImage = await picture.toImage(image.width, image.height);

    final byteData =
        await filteredImage.toByteData(format: ui.ImageByteFormat.png);

    if (!mounted) return;

    _filteredImage = byteData!.buffer.asUint8List();
    setState(() {});
  }

  Future<ui.Image> _loadImage(Uint8List data) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image image) {
      completer.complete(image);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _buildPhotoWithFilter(),
            ),
            if (_isProcessing) // Show the loading indicator while processing
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_isSaving) // Show saving loader when confirming image
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: _buildFilterSelector(),
            ),
            Positioned(
              right: 10.0,
              top: 10.0,
              child: ProIconButton(
                onTap: _confirmImage, // Call confirm image on tap
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWithFilter() {
    return ValueListenableBuilder(
      valueListenable: _filterColor,
      builder: (context, color, child) {
        return Image.memory(
          _filteredImage ?? widget.imageBytes,
          color: color.withOpacity(0.5),
          colorBlendMode: BlendMode.color,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildFilterSelector() {
    return FilterSelector(
      onFilterChanged: _onFilterChanged,
      filters: _filters,
    );
  }
}
