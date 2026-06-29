import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickerManager {
  PickerManager._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 60,
    double? maxWidth = 300,
    double? maxHeight = 300,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      return null;
    }
  }
}
