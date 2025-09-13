


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryImageUploader {
  final String cloudName;
  final String uploadPreset;
  final ImagePicker _picker = ImagePicker();

  CloudinaryImageUploader({
    required this.cloudName,
    required this.uploadPreset,
  });

  /// Picks image from gallery and uploads it to Cloudinary.
  /// Returns the uploaded image URL or null if failed/canceled.
  Future<String?> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      File imageFile = File(image.path);
      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final imageUrl = RegExp(r'"secure_url":"(.*?)"').firstMatch(responseData)?.group(1);
        return imageUrl;
      } else {
        debugPrint('Cloudinary upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}