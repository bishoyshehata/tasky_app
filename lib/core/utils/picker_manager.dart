import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickerManager {
  PickerManager._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      return null;
    }
  }
}
