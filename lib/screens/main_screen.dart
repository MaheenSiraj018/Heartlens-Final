import 'dart:io';

import 'package:flutter/material.dart';

import '../data/student.dart';
import '../utils/pdf_utils.dart';
import 'pdf_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late File pdfFile;
  List<Student> students = [
    Student(name: 'Sana Khan', age: '45', gender: 'Female', ST_Segment: 'Elevated in Lead II, III, and aVF, indicative of possible STEMI (ST-Elevation Myocardial Infarction) localized to the inferior wall of the heart.', Condition: 'High likelihood of Acute STEMI based on ECG data analysis.', followup: 'Recommend blood tests, echocardiography, and continuous monitoring.', lifestyle: 'Quit smoking, adopt a low-sodium diet, and ensure regular physical activity as guided by a healthcare professional.  ',localization: 'Inferior wall of the heart.',
    risk_level: 'High, Immediate medical attention is recommended.', urgent_action: 'Seek immediate consultation with a cardiologist for further evaluation and treatment.')
  ];

  void openPdfViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(pdf: pdfFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result '),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            pdfFile = await PdfUtils.generateAdvancedPDF(students);
            openPdfViewer();
          },
          child: const Text('View Report'),
        ),
      ),
    );
  }
}
