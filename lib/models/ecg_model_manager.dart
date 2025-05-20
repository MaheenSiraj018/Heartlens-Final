import 'package:tflite_flutter/tflite_flutter.dart';

class ECGModelManager {
  // Singleton instance
  static final ECGModelManager _instance = ECGModelManager._internal();
  factory ECGModelManager() => _instance;
  ECGModelManager._internal();

  // Model assets path
  static const String _modelPath = 'assets/models/tf_model.tflite';

  // Model interpreter
  Interpreter? _interpreter;
  bool _isLoaded = false;

  // Model categories
  static const Map<int, String> _categories = {
    0: 'mi',
    1: 'normal',
    2: 'abnormal_heartbeat',
    3: 'history_of_MI'
  };

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isLoaded = true;
      _logModelDetails();
    } catch (e) {
      throw Exception('Model loading failed: $e');
    }
  }

  void _logModelDetails() {
    if (_interpreter == null) return;

    print('╔══════════════════════════════╗');
    print('║      MODEL ARCHITECTURE      ║');
    print('╠══════════════════════════════╣');
    print('║ Input Tensors:');
    for (var i = 0; i < _interpreter!.getInputTensorsCount(); i++) {
      final tensor = _interpreter!.getInputTensor(i);
      print('║   ${tensor.name} - ${tensor.shape} (${tensor.type})');
    }
    print('╠══════════════════════════════╣');
    print('║ Output Tensors:');
    for (var i = 0; i < _interpreter!.getOutputTensorsCount(); i++) {
      final tensor = _interpreter!.getOutputTensor(i);
      print('║   ${tensor.name} - ${tensor.shape} (${tensor.type})');
    }
    print('╚══════════════════════════════╝');
  }

  Future<Map<String, dynamic>> predict(List<List<double>> signals) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('Model not initialized');
    }

    try {
      // Prepare input (assuming model expects [batch, 255] shape)
      final input = [signals[1]]; // Using Lead II by default
      final output = List.filled(1 * 4, 0.0).reshape([1, 4]);

      _interpreter!.run(input, output);

      return _formatPrediction(output[0]);
    } catch (e) {
      throw Exception('Prediction failed: $e');
    }
  }

  Map<String, dynamic> _formatPrediction(List<double> output) {
    final maxConfidence = output.reduce(math.max);
    final predictedIndex = output.indexOf(maxConfidence);

    return {
      'category': _categories[predictedIndex] ?? 'unknown',
      'confidence': maxConfidence,
      'probabilities': {
        for (var i = 0; i < output.length; i++)
          _categories[i] ?? 'class_$i': output[i]
      },
      'raw_output': output,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}