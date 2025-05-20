import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ECGPreprocessor {
  static const List<Map<String, int>> _leadCoordinates = [
    {'x': 150, 'y': 300, 'w': 493, 'h': 300},   // Lead I
    {'x': 646, 'y': 300, 'w': 489, 'h': 300},   // Lead II
    {'x': 1140, 'y': 300, 'w': 485, 'h': 300},   // Lead III
    {'x': 1630 , 'y': 300, 'w': 495, 'h': 300},   // Lead IV
    {'x': 150, 'y': 600, 'w': 493, 'h': 300},   // Lead V
    {'x': 646, 'y': 600, 'w': 489, 'h': 300},   // Lead VI
    {'x': 1140, 'y': 600, 'w': 485, 'h': 300},   // Lead VII
    {'x': 1630, 'y': 600, 'w': 495, 'h': 300},   // Lead VIII
    {'x': 150, 'y': 900, 'w': 493, 'h': 300},   // Lead IX
    {'x': 646, 'y': 900, 'w': 489, 'h': 300},   // Lead X
    {'x': 1140, 'y': 900, 'w': 485, 'h': 300},   // Lead XI
    {'x': 1630, 'y': 900, 'w': 495, 'h': 300},   // Lead XII
      ];

  Future<Map<String, dynamic>> processECGImage(File imageFile) async {
    try {
      final image = img.decodeImage(await imageFile.readAsBytes())!;
      final leads = _extractLeads(image);

      final processedSignals = <List<double>>[];
      final leadImages = <String>[];

      for (var i = 0; i < leads.length; i++) {
        final signal = _processLead(leads[i]);
        processedSignals.add(signal);
        leadImages.add(await _saveLeadImage(leads[i], i));
      }

      return {
        'signals': processedSignals,
        'lead_images': leadImages,
        'status': 'success'
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'status': 'failed'
      };
    }
  }

  List<img.Image> _extractLeads(img.Image image) {
    return _leadCoordinates.map((coord) {
      return img.copyCrop(
          image,
          coord['x']!,
          coord['y']!,
          coord['w']!,
          coord['h']!
      );
    }).toList();
  }

  List<double> _processLead(img.Image leadImage) {
    // 1. Convert to grayscale
    final gray = img.grayscale(leadImage);

    // 2. Apply adaptive threshold
    final binary = _adaptiveThreshold(gray);

    // 3. Extract signal
    final contour = _findSignalContour(binary);

    // 4. Normalize to 255 points
    return _resampleSignal(contour);
  }

  img.Image _adaptiveThreshold(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);
    const blockSize = 35;
    const constant = 7;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final luminance = img.luminance(image.getPixel(x, y));
        final avg = _localAverage(image, x, y, blockSize);
        result.setPixel(x, y, luminance < avg - constant
            ? img.ColorRgb8(0, 0, 0)
            : img.ColorRgb8(255, 255, 255));
      }
    }
    return result;
  }

  double _localAverage(img.Image image, int x, int y, int blockSize) {
    var sum = 0.0;
    var count = 0;

    final halfBlock = blockSize ~/ 2;
    final xStart = math.max(0, x - halfBlock);
    final xEnd = math.min(image.width - 1, x + halfBlock);
    final yStart = math.max(0, y - halfBlock);
    final yEnd = math.min(image.height - 1, y + halfBlock);

    for (var dy = yStart; dy <= yEnd; dy++) {
      for (var dx = xStart; dx <= xEnd; dx++) {
        sum += img.luminance(image.getPixel(dx, dy));
        count++;
      }
    }

    return sum / count;
  }

  List<math.Point> _findSignalContour(img.Image binaryImage) {
    final contour = <math.Point>[];

    for (var y = 0; y < binaryImage.height; y++) {
      final rowPixels = <int>[];

      for (var x = 0; x < binaryImage.width; x++) {
        if (img.luminance(binaryImage.getPixel(x, y)) < 128) {
          rowPixels.add(x);
        }
      }

      if (rowPixels.isNotEmpty) {
        final avgX = rowPixels.reduce((a, b) => a + b) / rowPixels.length;
        contour.add(math.Point(avgX, y.toDouble()));
      }
    }

    return contour;
  }

  List<double> _resampleSignal(List<math.Point> contour) {
    if (contour.isEmpty) return List.filled(255, 0.5);

    final normalized = <double>[];
    final targetLength = 255;
    final step = contour.length / targetLength;

    for (var i = 0; i < targetLength; i++) {
      final index = (i * step).clamp(0, contour.length - 1).toInt();
      normalized.add(contour[index].y / contour.length);
    }

    return normalized;
  }

  Future<String> _saveLeadImage(img.Image leadImage, int index) async {
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File('${tempDir.path}/lead_$index.png');
    await file.writeAsBytes(img.encodePng(leadImage));
    return file.path;
  }

}
