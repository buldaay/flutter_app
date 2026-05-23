import 'package:flutter/services.dart';

class VlcIntentService {
  static const MethodChannel _channel = MethodChannel('tv_media_launcher');

  static Future<bool> isVlcInstalled() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkVlcInstalled');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openVideoWithVlc(String videoPath) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('openVideoWithVlc', {'path': videoPath});
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
