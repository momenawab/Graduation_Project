import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraImageConverter {
  CameraImageConverter._();

  static Uint8List? cameraImageToJpeg(CameraImage image, {int quality = 70}) {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return yuv420ToJpeg(image, quality: quality);
      case ImageFormatGroup.bgra8888:
        return bgra8888ToJpeg(image, quality: quality);
      case ImageFormatGroup.jpeg:
        return Uint8List.fromList(image.planes.first.bytes);
      default:
        return null;
    }
  }

  static Uint8List yuv420ToJpeg(CameraImage image, {int quality = 70}) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final out = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex =
            (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

        if (yIndex >= yBytes.length ||
            uvIndex >= uBytes.length ||
            uvIndex >= vBytes.length) {
          continue;
        }

        final yp = yBytes[yIndex];
        final up = uBytes[uvIndex];
        final vp = vBytes[uvIndex];

        int r = (yp + 1.402 * (vp - 128)).round();
        int g =
            (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
        int b = (yp + 1.772 * (up - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return Uint8List.fromList(img.encodeJpg(out, quality: quality));
  }

  static Uint8List bgra8888ToJpeg(CameraImage image, {int quality = 70}) {
    final plane = image.planes.first;
    final out = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: plane.bytes.buffer,
      rowStride: plane.bytesPerRow,
      order: img.ChannelOrder.bgra,
    );
    return Uint8List.fromList(img.encodeJpg(out, quality: quality));
  }
}
