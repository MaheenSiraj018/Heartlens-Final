import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/report_generator_bloc.dart';
import '../states/report_generator_state.dart';
import '../events/report_generator_event.dart';
import '../data/report_model.dart';
import './localization_screen.dart';
import 'dart:math'; // Add this import at the top of your file

import '../utils/pdf_utils.dart';
import 'pdf_screen.dart';

class ResultScreen extends StatefulWidget {

  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late File pdfFile;
  Report report = Report.defaultValues();
  bool _isLoading = true;
  Map<String, dynamic> reportData = {};

  // Dummy data fallback (NSTEMI example)
  // final Map<String, dynamic> _dummyData = {
  //   'st_segment': 'ST segment depression detected (0.5mm)',
  //   'condition': 'Non-ST Elevation Myocardial Infarction (NSTEMI)',
  //   'localization': 'Inferior Wall',
  //   'risk_level': 'High Risk',
  //   'what_this_means': 'Partial blockage in heart arteries detected',
  //   'urgent_action': 'Visit emergency room within 2 hours',
  //   'followup': 'Consult cardiologist within 48 hours',
  //   'lifestyle': 'Reduce salt intake, avoid strenuous activities'
  // };

  @override
  void initState() {
    super.initState();
    _triggerReportGeneration();
  }

  final List<Map<String, dynamic>> randomResults = [
    {
      'condition': 'Myocardial Infarction (MI)',
      'type': 'STEMI',
      'location': 'Anterior',
      'confidence': '92%'
    },
    {
      'condition': 'Myocardial Infarction (MI)',
      'type': 'STEMI',
      'location': 'Lateral',
      'confidence': '92%'
    },
    {
      'condition': 'Myocardial Infarction (MI)',
      'type': 'STEMI',
      'location': 'Inferior',
      'confidence': '92%'
    },
    {
      'condition': 'Normal',
      'type': '',
      'location': '',
      'confidence': '98%'
    },
    {
      'condition': 'Abnormal',
      'type': 'Arrhythmia',
      'location': '',
      'confidence': '87%'
    },

  ];

  // void _triggerReportGeneration() {
  //   setState(() => _isLoading = true);
  //   context.read<ReportGeneratorBloc>().add(
  //       GenerateReport({
  //         'diagnosis': 'Abnormal heartbeat detected',
  //         'ST_Elevated_MI_Detected': 'no',
  //         'MI_Type': 'No MI Detected',
  //         'confidence': 0.92,
  //       })
  //   );
  // }
  void _triggerReportGeneration() {
    setState(() => _isLoading = true);
    final random = Random();
    final result = randomResults[random.nextInt(randomResults.length)];

    // Prepare report data based on the condition
    switch (result['condition']) {
      case 'Myocardial Infarction (MI)':
        reportData = {
          'diagnosis': 'Myocardial Infarction detected',
          'ST_Elevated_MI_Detected': 'yes',
          'MI_Type': result['type'] ?? 'STEMI',  // Use actual type
          'MI_Location': result['location'] ?? '', // Include location from result
          'confidence': double.parse(result['confidence']?.replaceAll('%', '') ?? '0') / 100,
        };
        break;

      case 'Normal':
        reportData = {
          'diagnosis': 'Normal ECG reading',
          'ST_Elevated_MI_Detected': 'no',
          'MI_Type': 'No MI Detected',
          'confidence': double.parse(result['confidence']?.replaceAll('%', '') ?? '0') / 100,
        };
        break;

      case 'Abnormal':
        reportData = {
          'diagnosis': 'Abnormal ECG - ${result['type']}',
          'ST_Elevated_MI_Detected': 'no',
          'MI_Type': 'No MI Detected',
          'confidence': double.parse(result['confidence']?.replaceAll('%', '') ?? '0') / 100,
        };
        break;

      default:
        reportData = {
          'diagnosis': 'Inconclusive results',
          'ST_Elevated_MI_Detected': 'no',
          'MI_Type': 'No MI Detected',
          'confidence': 0.50,
        };
    }

    context.read<ReportGeneratorBloc>().add(GenerateReport(reportData));
  }

  void _viewLocalization() {
    if (reportData['ST_Elevated_MI_Detected'] == 'yes') {
      // Use location as the primary identifier
      String location = reportData['MI_Location'] ?? '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalizationScreen(
            miType: location.isNotEmpty ? location : 'STEMI',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalizationScreen(
            miType: 'No MI Detected',
          ),
        ),
      );
    }
  }
  Future<void> _generatePdf() async {
    Navigator.pushNamed(context, '/input');
    // setState(() => _isLoading = true);
    // try {
    //   pdfFile = await PdfUtils.generateAdvancedPDF([report]);
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => PdfScreen(pdf: pdfFile)),
    //   );
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1B0E0E),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            content,
            style: const TextStyle(
              color: Color(0xFF1B0E0E),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return BlocConsumer<ReportGeneratorBloc, ReportGeneratorState>(
  //     listener: (context, state) {
  //       if (state is ReportGeneratorError) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Error: ${state.message}')),
  //         );
  //         // Fallback to dummy data if API fails
  //         setState(() {
  //           report = Report(
  //             stSegmentFindings: _dummyData['st_segment']!,
  //             conditionDetected: _dummyData['condition']!,
  //             localization: _dummyData['localization']!,
  //             riskLevel: _dummyData['risk_level']!,
  //             whatThisMeans: _dummyData['what_this_means']!,
  //             urgentActions: _dummyData['urgent_action']!,
  //             followUpRecommendations: _dummyData['followup']!,
  //             lifestyleChanges: _dummyData['lifestyle']!,
  //           );
  //           _isLoading = false;
  //         });
  //       }
  //     },
  //     builder: (context, state) {
  //       // Update UI when new data arrives
  //       if (state is ReportGeneratorSuccess) {
  //         report = Report(
  //           stSegmentFindings: state.report['st_segment'] ?? _dummyData['st_segment']!,
  //           conditionDetected: state.report['condition'] ?? _dummyData['condition']!,
  //           localization: state.report['localization'] ?? _dummyData['localization']!,
  //           riskLevel: state.report['risk_level'] ?? _dummyData['risk_level']!,
  //           whatThisMeans: state.report['what_this_means'] ?? _dummyData['what_this_means']!,
  //           urgentActions: state.report['urgent_action'] ?? _dummyData['urgent_action']!,
  //           followUpRecommendations: state.report['followup'] ?? _dummyData['followup']!,
  //           lifestyleChanges: state.report['lifestyle'] ?? _dummyData['lifestyle']!,
  //         );
  //         _isLoading = false;
  //       }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportGeneratorBloc, ReportGeneratorState>(
      listener: (context, state) {
        if (state is ReportGeneratorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
          setState(() => _isLoading = false);
        }
      },
      builder: (context, state) {
        if (state is ReportGeneratorSuccess) {
          // Only update if we have actual Gemini data
          if (state.report.isNotEmpty) {
            report = Report(
              stSegmentFindings: state.report['st_segment'] ?? 'No ST segment data available',
              conditionDetected: state.report['condition'] ?? 'No diagnosis available',
              localization: state.report['localization'] ?? 'Location not specified',
              riskLevel: state.report['risk_level'] ?? 'Risk level not determined',
              whatThisMeans: state.report['what_this_means'] ?? 'Explanation not available',
              urgentActions: state.report['urgent_action'] ?? 'No urgent actions recommended',
              followUpRecommendations: state.report['followup'] ?? 'No follow-up recommendations',
              lifestyleChanges: state.report['lifestyle'] ?? 'No lifestyle suggestions',
            );
          }
          _isLoading = false;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFCF8F8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFD1D1),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'ECG Analysis Summary',
              style: TextStyle(
                color: Color(0xFF1B0E0E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ECG Image Display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/img.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // All Report Sections
                _buildSection('ST Segment Elevations', report.stSegmentFindings),
                _buildSection('Diagnostic Insights', report.conditionDetected),
                _buildSection('Risk Level', report.riskLevel),
                _buildSection('What This Means', report.whatThisMeans),
                _buildSection('Urgent Actions', report.urgentActions),
                _buildSection('Follow Up', report.followUpRecommendations),
                _buildSection('Lifestyle Changes', report.lifestyleChanges),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD23939),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          _viewLocalization(); // Pass your existing reportData
                        },
                        child: const Text(
                          'View Localization',
                          style: TextStyle(
                            color: Color(0xFFFCF8F8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD23939),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: _generatePdf,
                        child: const Text(
                          'View PDF Report',
                          style: TextStyle(
                            color: Color(0xFFFCF8F8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Generated by HeartLens',
                    style: TextStyle(
                      color: Color(0xFF1B0E0E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/report_generator_bloc.dart';
// import '../states/report_generator_state.dart';
// import '../events/report_generator_event.dart';
// import '../data/student.dart';
// import '../utils/pdf_utils.dart';
// import 'pdf_screen.dart';
//
// class ResultScreen extends StatefulWidget {
//   const ResultScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ResultScreen> createState() => ResultScreenState();
// }
//
// class ResultScreenState extends State<ResultScreen> {
//   late File pdfFile;
//   List<Student> students = [Student.getDefault()]; // Initialize with default values
//
//   // Dummy ML Results - To be replaced with actual model output
//   final Map<String, dynamic> dummyResults = {
//     "diagnosis": "Myocardial Infarction (MI)",
//     "ST_Elevated_MI_Detected": "Yes",
//     "MI_Type": "Inferior Wall",
//     "confidence": 0.96,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     // Trigger report generation with dummy data (replace with real data later)
//     context.read<ReportGeneratorBloc>().add(GenerateReport(dummyResults));
//   }
//
//   void openPdfViewer() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PdfScreen(pdf: pdfFile),
//       ),
//     );
//   }
//
//   void viewLocalization() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Localization'),
//           content: Text(students.first.localization),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Map<String, String> _parseGeminiResponse(String reportText) {
//     return {
//       'condition': _extractSection(reportText, 'Condition Detected:'),
//       'st_segment': _extractSection(reportText, 'ST Segment Findings:'),
//       'localization': _extractSection(reportText, 'Localization:'),
//       'risk_level': _determineRiskLevel(reportText),
//       'urgent_action': _extractSection(reportText, 'Urgent Action:'),
//       'followup': _extractSection(reportText, 'Follow Up:'),
//       'lifestyle': _extractSection(reportText, 'LifeStyle:'),
//     };
//   }
//
//   String _extractSection(String text, String section) {
//     final pattern = RegExp('$section(.*?)(?=\\n\\w+|\\Z)', dotAll: true);
//     return pattern.firstMatch(text)?.group(1)?.trim() ?? 'Data not available';
//   }
//
//   String _determineRiskLevel(String text) {
//     if (text.contains('STEMI')) return 'Critical';
//     if (text.contains('NSTEMI')) return 'High';
//     if (text.contains('Abnormal')) return 'Moderate';
//     return 'Normal';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ReportGeneratorBloc, ReportGeneratorState>(
//       builder: (context, state) {
//         if (state is ReportGeneratorSuccess) {
//           final report = _parseGeminiResponse(state.reportText);
//           students = [
//             Student(
//               ST_Segment: report['st_segment']!,
//               Condition: report['condition']!,
//               followup: report['followup']!,
//               lifestyle: report['lifestyle']!,
//               localization: report['localization']!,
//               risk_level: report['risk_level']!,
//               urgent_action: report['urgent_action']!,
//             ),
//           ];
//         }
//
//         return Scaffold(
//           backgroundColor: const Color(0xFFFCF8F8),
//           appBar: AppBar(
//             backgroundColor: const Color(0xFFFFD1D1),
//             elevation: 0,
//             centerTitle: true,
//             title: const Text(
//               'ECG Analysis Summary',
//               style: TextStyle(
//                 color: Color(0xFF1B0E0E),
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           body: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFCF8F8),
//                       borderRadius: BorderRadius.circular(12.0),
//                       image: const DecorationImage(
//                         image: AssetImage('assets/images/img.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // ST Segment Elevations Section
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Text(
//                     'ST Segment Elevations',
//                     style: TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     students[0].ST_Segment,
//                     style: const TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//
//                 // Diagnostic Insights
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Text(
//                     'Diagnostic Insights',
//                     style: TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     students[0].Condition,
//                     style: const TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//
//                 // Risk Level
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Text(
//                     'Risk Level',
//                     style: TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     students[0].risk_level,
//                     style: const TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//
//                 // Buttons Section
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       // View Localization Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD23939),
//                           minimumSize: const Size(double.infinity, 48),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                         ),
//                         onPressed: viewLocalization,
//                         child: const Text(
//                           'View Localization',
//                           style: TextStyle(
//                             color: Color(0xFFFCF8F8),
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16.0),
//
//                       // View PDF Report Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD23939),
//                           minimumSize: const Size(double.infinity, 48),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                         ),
//                         onPressed: () async {
//                           pdfFile = await PdfUtils.generateAdvancedPDF(students);
//                           openPdfViewer();
//                         },
//                         child: const Text(
//                           'View PDF Report',
//                           style: TextStyle(
//                             color: Color(0xFFFCF8F8),
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Footer
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: Text(
//                     'Generated by HeartLens',
//                     style: TextStyle(
//                       color: Color(0xFF1B0E0E),
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import '../data/student.dart';
// import '../utils/pdf_utils.dart';
// import 'pdf_screen.dart';
//
// class ResultScreen extends StatefulWidget {
//   const ResultScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ResultScreen> createState() => ResultScreenState();
// }
//
// class ResultScreenState extends State<ResultScreen> {
//   late File pdfFile;
//
//   // Sample student data
//   List<Student> students = [
//     Student(
//       name: 'Sana Khan',
//       age: '45',
//       gender: 'Female',
//       ST_Segment:
//       'Elevated in Lead II, III, and aVF, indicative of possible STEMI (ST-Elevation Myocardial Infarction) localized to the inferior wall of the heart.',
//       Condition:
//       'High likelihood of Acute STEMI based on ECG data analysis.',
//       followup:
//       'Recommend blood tests, echocardiography, and continuous monitoring.',
//       lifestyle:
//       'Quit smoking, adopt a low-sodium diet, and ensure regular physical activity as guided by a healthcare professional.',
//       localization: 'Inferior wall of the heart.',
//       risk_level: 'High, Immediate medical attention is recommended.',
//       urgent_action:
//       'Seek immediate consultation with a cardiologist for further evaluation and treatment.',
//     ),
//   ];
//
//   void openPdfViewer() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PdfScreen(pdf: pdfFile),
//       ),
//     );
//   }
//
//   void viewLocalization() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Localization'),
//           content: Text(students.first.localization),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF8F8),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFD1D1),
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'ECG Analysis Summary',
//           style: TextStyle(
//             color: Color(0xFF1B0E0E),
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Section
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCF8F8),
//                   borderRadius: BorderRadius.circular(12.0),
//                   image: const DecorationImage(
//                     image: AssetImage('assets/images/img.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             // ST Segment Elevations Section
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Text(
//                 'ST Segment Elevations',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 19,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'The ECG shows ST segment elevations in multiple leads.',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Text(
//                 'Diagnostic Insights',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 19,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'The ECG has a high likelihood of acute STEMI. The patient should be treated as emergency and sent to thee cath lab for immediate reperfusion therapy.',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Text(
//                 'Risk Level',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 19,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 'High',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             // Buttons Section
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column( // Changed Row to Column
//                 children: [
//                   // View Localization Button
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFD23939),
//                       minimumSize: const Size(double.infinity, 48), // Ensures full width
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                     ),
//     onPressed: ()  {
//     Navigator.pushNamed(context, '/localization');
//     }
//                     ,
//
//                     child: const Text(
//                       'View Localization',
//                       style: TextStyle(
//                         color: Color(0xFFFCF8F8),
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0), // Add spacing between buttons
//                   // View PDF Report Button
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFD23939),
//                       minimumSize: const Size(double.infinity, 48), // Ensures full width
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                     ),
//                     onPressed: ()  {
//                       Navigator.pushNamed(context, '/input');
//
//                       // pdfFile = await PdfUtils.generateAdvancedPDF(students);
//                       // openPdfViewer();
//                     },
//                     child: const Text(
//                       'View PDF Report',
//                       style: TextStyle(
//                         color: Color(0xFFFCF8F8),
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Text(
//                 'Generated by HeartLens',
//                 style: TextStyle(
//                   color: Color(0xFF1B0E0E),
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
