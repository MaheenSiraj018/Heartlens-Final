import 'dart:io';

import 'package:flutter/material.dart';
import '../data/student.dart';
import '../utils/pdf_utils.dart';
import 'pdf_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  late File pdfFile;

  // Sample student data
  List<Student> students = [
    Student(
      name: 'Sana Khan',
      age: '45',
      gender: 'Female',
      ST_Segment:
      'Elevated in Lead II, III, and aVF, indicative of possible STEMI (ST-Elevation Myocardial Infarction) localized to the inferior wall of the heart.',
      Condition:
      'High likelihood of Acute STEMI based on ECG data analysis.',
      followup:
      'Recommend blood tests, echocardiography, and continuous monitoring.',
      lifestyle:
      'Quit smoking, adopt a low-sodium diet, and ensure regular physical activity as guided by a healthcare professional.',
      localization: 'Inferior wall of the heart.',
      risk_level: 'High, Immediate medical attention is recommended.',
      urgent_action:
      'Seek immediate consultation with a cardiologist for further evaluation and treatment.',
    ),
  ];

  void openPdfViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(pdf: pdfFile),
      ),
    );
  }

  void viewLocalization() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Localization'),
          content: Text(students.first.localization),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF8F8),
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/img.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // ST Segment Elevations Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'ST Segment Elevations',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'The ECG shows ST segment elevations in multiple leads.',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 14,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Diagnostic Insights',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'The ECG has a high likelihood of acute STEMI. The patient should be treated as emergency and sent to thee cath lab for immediate reperfusion therapy.',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 14,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Risk Level',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'High',
                style: TextStyle(
                  color: Color(0xFF1B0E0E),
                  fontSize: 14,
                ),
              ),
            ),
            // Buttons Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column( // Changed Row to Column
                children: [
                  // View Localization Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD23939),
                      minimumSize: const Size(double.infinity, 48), // Ensures full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: viewLocalization,
                    child: const Text(
                      'View Localization',
                      style: TextStyle(
                        color: Color(0xFFFCF8F8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Add spacing between buttons
                  // View PDF Report Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD23939),
                      minimumSize: const Size(double.infinity, 48), // Ensures full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: ()  {
                      Navigator.pushReplacementNamed(context, '/input');

                      // pdfFile = await PdfUtils.generateAdvancedPDF(students);
                      // openPdfViewer();
                    },
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
  }
}
