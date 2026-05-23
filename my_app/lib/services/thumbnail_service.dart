import 'package:flutter/services.dart';

class ThumbnailService {
  static const MethodChannel _channel = MethodChannel('tv_media_launcher');

  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final String? result = await _channel.invokeMethod<String>('generateThumbnail', {'path': videoPath});
      return result;
    } catch (_) {
      return null;
    }
  }
}
