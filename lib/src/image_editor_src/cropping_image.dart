import 'dart:io';
import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class CroppingImage {
  CroppingImage();

  Future<Uint8List> crop({required Uint8List imageBytes}) async {
    // Convert Uint8List to File
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');

    // Write Uint8List to File
    await tempFile.writeAsBytes(imageBytes);

    try {
      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.png,
      );

      if (croppedFile == null) {
        return imageBytes;
      }

      // Read the cropped image file back into Uint8List
      final croppedImageBytes = await croppedFile.readAsBytes();
      return croppedImageBytes;
    } catch (e) {
      print(e);
      return imageBytes;
    }
  }
}
