class Report {
  // Diagnostic Sections
  final String stSegmentFindings;
  final String conditionDetected;
  final String localization;
  final String riskLevel;

  // Patient Explanation Sections
  final String whatThisMeans;
  final String urgentActions;
  final String followUpRecommendations;
  final String lifestyleChanges;



  Report({
    // Diagnostic
    required this.stSegmentFindings,
    required this.conditionDetected,
    required this.localization,
    required this.riskLevel,

    // Patient Explanation
    required this.whatThisMeans,
    required this.urgentActions,
    required this.followUpRecommendations,
    required this.lifestyleChanges,

  });

  factory Report.defaultValues() {
    return Report(
      // Diagnostic Defaults
      stSegmentFindings: 'ST segment analysis in progress',
      conditionDetected: 'Diagnosis being generated',
      localization: 'Localization not determined',
      riskLevel: 'Risk level being assessed',

      // Patient Explanation Defaults
      whatThisMeans: 'Explanation being prepared',
      urgentActions: 'Awaiting analysis results',
      followUpRecommendations: 'Recommendations pending',
      lifestyleChanges: 'Maintain healthy habits until results arrive',
    );
  }

  // Helper method to convert to map for PDF generation
  Map<String, String> toMap() {
    return {
      'ST Segment Findings': stSegmentFindings,
      'Condition Detected': conditionDetected,
      'Localization': localization,
      'Risk Level': riskLevel,
      'What This Means': whatThisMeans,
      'Urgent Actions': urgentActions,
      'Follow Up': followUpRecommendations,
      'Lifestyle Changes': lifestyleChanges,
      
    };
  }
}