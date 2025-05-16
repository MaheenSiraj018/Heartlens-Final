class EcgAnalysisResult {
  final bool hasSTEMI;
  final String? stemiType; // 'anterior', 'inferior', 'lateral', or null if no STEMI
  final double confidenceScore;

  EcgAnalysisResult({
    required this.hasSTEMI,
    this.stemiType,
    required this.confidenceScore,
  });

  @override
  String toString() {
    return 'STEMI: $hasSTEMI, Type: $stemiType, Confidence: ${(confidenceScore * 100).toStringAsFixed(2)}%';
  }
}