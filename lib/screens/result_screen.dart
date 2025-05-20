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

  @override
  void initState() {
    super.initState();
    _triggerReportGeneration();
  }


   Future<void> analyzeECGAndGenerateReport(BuildContext context, File ecgImage) async {
    try {
      final processed = await _preprocessor.processECGImage(ecgImage);
      if (processed['status'] == 'failed') throw processed['error'];
      final prediction = await _modelManager.predict(processed['signals']);
      
      context.read<ReportGeneratorBloc>().add(GenerateReport(reportData));
    } catch (e) {
      context.read<ReportGeneratorBloc>().add(ReportGenerationFailed(e.toString()));
    }
  }

  Map<String, dynamic> _createReportData(
    Map<String, dynamic> prediction,
    Map<String, dynamic> processed
  ) {
    return {
      'diagnosis': prediction['category'],
      'ST_Elevated_MI_Detected': prediction['category'].contains('MI') ? 'yes' : 'no',
      'MI_Type': prediction['category'],
      'confidence': prediction['confidence'],
      'signals': processed['signals'],
      'lead_images': processed['lead_images'],
    };
  }

  void dispose() {
    _preprocessor.dispose();
    _modelManager.dispose();
  }
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
