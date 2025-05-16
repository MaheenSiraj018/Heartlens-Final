import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../events/report_generator_event.dart';
import '../states/report_generator_state.dart';

class ReportGeneratorBloc extends Bloc<ReportGeneratorEvent, ReportGeneratorState> {
  static String? _lastGeneratedReport; // Stores report globally for PDF

  ReportGeneratorBloc() : super(ReportGeneratorInitial()) {
    on<GenerateReport>(_onGenerateReport);
  }

  Future<void> _onGenerateReport(
      GenerateReport event,
      Emitter<ReportGeneratorState> emit,
      ) async {
    emit(ReportGeneratorLoading());

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: dotenv.env['PDF_API_KEY']!,
      );

      final prompt = _buildPrompt(event.mlResults);
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        emit(ReportGeneratorError('Empty response from Gemini API'));
        return;
      }

      _lastGeneratedReport = response.text;
      final parsedReport = _parseFullReport(response.text!);

      if (parsedReport.isEmpty) {
        emit(ReportGeneratorError('Failed to parse Gemini response'));
        return;
      }

      emit(ReportGeneratorSuccess(parsedReport));

    } catch (e) {
      emit(ReportGeneratorError('Failed to generate report: ${e.toString()}'));
    }
  }

  String _buildPrompt(Map<String, dynamic> mlResults) {
    return """
TASK: Generate a cardiac report on the basis of results provided.

ANALYSIS RESULTS:
${jsonEncode(mlResults)}
- Diagnosis:(MI(myocardial Infarction)/Normal heartbeat/Abnormal Heartbeat)
- ST_Elevated_MI_Detected: (Yes/No)
- MI_Type:(Anterior Wall/Lateral Wall/Inferior Wall)


REPORT TEMPLATE:

ST Segment Findings: (Clearly state ${mlResults['ST_Elevated_MI_Detected'] == 'Yes' ? 'ST elevations detected' : 'No ST elevations detected'})

Condition Detected: (Should Include to the point diagnosis in medical terms).
Localization: (Simply mention the MI_type in medical terms)
Risk Level: (As per the diagnosis, give to the point risk level)

What this Means: (Give diagnosis and risk level in easily understandable terms, don't use medical terms).

Urgent Action: (Give for user's persepctive in simple terms).
Follow Up: (Give for user's persepctive in simple terms).
LifeStyle: (Give for user's persepctive in simple terms).

OUTPUT: 
- Must be according to given template. 
- Must not include any markdowns or * or -.
- Must include 1-2 line sentence for each section of report. """;
  }

  Map<String, String> _parseFullReport(String reportText) {
    try {
      return {
        'st_segment': _extractExactSection(reportText, 'ST Segment Findings:'),
        'condition': _extractExactSection(reportText, 'Condition Detected:'),
        'localization': _extractExactSection(reportText, 'Localization:'),
        'risk_level': _extractExactSection(reportText, 'Risk Level:'),
        'what_this_means': _extractExactSection(reportText, 'What this Means:'),
        'urgent_action': _extractExactSection(reportText, 'Urgent Action:'),
        'followup': _extractExactSection(reportText, 'Follow Up:'),
        'lifestyle': _extractExactSection(reportText, 'LifeStyle:'),
      };
    } catch (e) {
      return {};
    }
  }

  String _extractExactSection(String text, String sectionHeader) {
    final start = text.indexOf(sectionHeader);
    if (start == -1) return 'Data not available';

    final contentStart = start + sectionHeader.length;
    final end = text.indexOf('\n', contentStart);

    return end == -1
        ? text.substring(contentStart).trim()
        : text.substring(contentStart, end).trim();
  }

  // Keep your old parse method if needed for backward compatibility
  Map<String, String> _parseReport(String reportText) {
    return {
      'medical': _extractSection(reportText, 'Condition Detected'),
      'patient': _extractSection(reportText, 'What This Means'),
      'patient1': _extractSection(reportText, 'Recommendations'),
    };
  }

  // Keep your old extract method if needed
  String _extractSection(String text, String section) {
    final pattern = RegExp('$section:(.*?)(?=\\n\\w+|\\Z)', dotAll: true);
    return pattern.firstMatch(text)?.group(1)?.trim() ?? 'Not available';
  }

  static String? getLastReport() => _lastGeneratedReport;
}


// import 'dart:convert';
// import 'package:bloc/bloc.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../events/report_generator_event.dart';
// import '../states/report_generator_state.dart';
//
// class ReportGeneratorBloc extends Bloc<ReportGeneratorEvent, ReportGeneratorState> {
//   static String? _lastGeneratedReport; // Stores report globally for PDF
//
//   ReportGeneratorBloc() : super(ReportGeneratorInitial()) {
//     on<GenerateReport>(_onGenerateReport);
//   }
//
//   Future<void> _onGenerateReport(
//       GenerateReport event,
//       Emitter<ReportGeneratorState> emit,
//       ) async {
//     emit(ReportGeneratorLoading());
//
//     try {
//       final model = GenerativeModel(
//         model: 'gemini-1.5-flash-latest',
//         apiKey: dotenv.env['PDF_API_KEY']!,
//       );
//
//       final prompt = _buildPrompt(event.mlResults);
//       final response = await model.generateContent([Content.text(prompt)]);
//       if (response.text == null || response.text!.isEmpty) {
//         emit(ReportGeneratorError('Empty response from Gemini API'));
//         return;
//       }
//
//       final parsedReport = _parseReport(response.text!);
//
//       if (parsedReport.isEmpty) {
//         emit(ReportGeneratorError('Failed to parse Gemini response'));
//         return;
//       }
//
//       emit(ReportGeneratorSuccess(parsedReport));
//
//     } catch (e) {
//       emit(ReportGeneratorError('Failed to generate report: ${e.toString()}'));
//     }
//   }
//
//   String _buildPrompt(Map<String, dynamic> mlResults) {
//     return """
// TASK: Generate a cardiac report on the basis of results provided.
//
// ANALYSIS RESULTS:
// ${jsonEncode(mlResults)}
// - Diagnosis:(MI(myocardial Infarction)/Normal heartbeat/Abnormal Heartbeat)
// - ST_Elevated_MI_Detected: (Yes/No)
// - MI_Type:(Anterior Wall/Lateral Wall/Inferior Wall)
//
//
// REPORT TEMPLATE:
//
// ST Segment Findings: (Clearly state ${mlResults['ST_Elevated_MI_Detected'] == 'Yes' ? 'ST elevations detected' : 'No ST elevations detected'})
//
// Condition Detected: (Should Include to the point diagnosis in medical terms).
// Localization: (Simply mention the MI_type in medical terms)
// Risk Level: (As per the diagnosis, give to the point risk level)
//
// What this Means: (Give diagnosis and risk level in easily understandable terms, don't use medical terms).
//
// Urgent Action: (Give for user's persepctive in simple terms).
// Follow Up: (Give for user's persepctive in simple terms).
// LifeStyle: (Give for user's persepctive in simple terms).
//
// OUTPUT:
// - Must be according to given template.
// - Must not include any markdowns or * or -.
// - Must include 1-2 line sentence for each section of report. """;
//   }
//
//   Map<String, String> _parseReport(String reportText) {
//     return {
//       'medical': _extractSection(reportText, 'Condition Detected'),
//       'patient': _extractSection(reportText, 'What This Means'),
//       'patient1': _extractSection(reportText, 'Recommendations'),
//     };
//   }
//
//   String _extractSection(String text, String section) {
//     final pattern = RegExp('$section:(.*?)(?=\\n\\w+|\\Z)', dotAll: true);
//     return pattern.firstMatch(text)?.group(1)?.trim() ?? 'Not available';
//   }
//
//   static String? getLastReport() => _lastGeneratedReport;
// }