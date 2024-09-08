import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageFilterer {
  final Uint8List imageBytes;
  late img.Image _image;

  ImageFilterer(this.imageBytes) {
    _image = img.decodeImage(imageBytes)!;
  }

  /// Applies a grayscale filter to the image.
  Uint8List applyGrayscale() {
    img.Image grayscaleImage = img.grayscale(_image);
    return Uint8List.fromList(img.encodeJpg(grayscaleImage));
  }

  /// Applies a sepia filter to the image.
  Uint8List applySepia() {
    img.Image sepiaImage = img.sepia(_image);
    return Uint8List.fromList(img.encodeJpg(sepiaImage));
  }

  /// Applies a brightness filter to the image.
  Uint8List applyBrightness(double factor) {
    img.Image brightImage = img.adjustColor(_image, brightness: factor);
    return Uint8List.fromList(img.encodeJpg(brightImage));
  }

  /// Applies a contrast filter to the image.
  Uint8List applyContrast(double factor) {
    img.Image contrastImage = img.adjustColor(_image, contrast: factor);
    return Uint8List.fromList(img.encodeJpg(contrastImage));
  }

  /// Applies a blur filter to the image.
  Uint8List applyBlur(double sigmaX, double sigmaY) {
    img.Image blurImage = img.gaussianBlur(_image, radius: 30);
    return Uint8List.fromList(img.encodeJpg(blurImage));
  }
}
