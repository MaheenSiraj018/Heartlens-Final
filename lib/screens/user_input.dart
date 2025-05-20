import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../data/student.dart';
import '../utils/pdf_utils.dart';
import 'pdf_screen.dart';
import '../blocs/user_data_bloc.dart';
import '../events/user_data_event.dart';
import '../data/user_model.dart';
import '../data/report_model.dart';
import '../blocs/report_generator_bloc.dart';
import '../events/report_generator_event.dart';
import '../states/report_generator_state.dart';

class UserInput extends StatefulWidget {
  const UserInput({Key? key}) : super(key: key);

  @override
  State<UserInput> createState() => ResultScreenState();
}

class ResultScreenState extends State<UserInput> {
  late File pdfFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  
  void openPdfViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(pdf: pdfFile),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          backgroundColor: const Color(0xFFF3E7E7), // Custom background color
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK", style:TextStyle(fontSize: 20, color: Color(0xFFD23939) )),
            ),
          ],
        );
      },
    );
  }
  Future<void> _validateAndProceed() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final gender = genderController.text.trim();

    if (name.isEmpty || age.isEmpty || gender.isEmpty) {
      _showErrorDialog("All fields are required. Please fill in all the details.");
      return;
    }

    // Save user data to BLoC
    context.read<UserDataBloc>().add(AddUserData(User(name: name, age: age, gender: gender)));

    try {
      // Get the latest Gemini report from BLoC state
      final reportState = context.read<ReportGeneratorBloc>().state;

      if (reportState is ReportGeneratorSuccess) {
        // Generate PDF with dynamic Gemini data + user input
        debugPrint('Gemini Report: ${reportState.report}');

        pdfFile = await PdfUtils.generateAdvancedPDF(
          [Student( // Pass as named parameter
            name: name,
            age: age,
            gender: gender,
            ST_Segment: reportState.report['st_segment'] ?? 'No ST segment data',
            Condition: reportState.report['condition'] ?? 'No diagnosis available',
            followup: reportState.report['followup'] ?? 'No follow-up recommendations',
            lifestyle: reportState.report['lifestyle'] ?? 'No lifestyle suggestions',
            localization: reportState.report['localization'] ?? 'Location not specified',
            risk_level: reportState.report['risk_level'] ?? 'Risk level not determined',
            urgent_action: reportState.report['urgent_action'] ?? 'No urgent actions recommended',
            whatThisMeans: reportState.report['what_this_means'] ?? 'No explanation available', // Add this
          ),
       ] );

        openPdfViewer();
      } else {
        _showErrorDialog("Medical analysis not ready. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Failed to generate report: ${e.toString()}");
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF8F8),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main'); // Handles the back navigation
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0E0E)),
        ),
      ),
      body: Column(
        children: [
          // Title and Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  "Let's get to know you better for a personalized experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1B0E0E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter your name, age, and gender for report generation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1B0E0E),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Input Fields
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Name Input
                    CustomInputField(
                      controller: nameController,
                      placeholder: "Your name",
                    ),
                    const SizedBox(height: 16),

                    // Age Input
                    CustomInputField(
                      controller: ageController,
                      placeholder: "Your age",
                    ),
                    const SizedBox(height: 16),

                    // Gender Input
                    CustomInputField(
                      controller: genderController,
                      placeholder: "Your gender",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Continue Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD23939),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _validateAndProceed,
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Input Field Widget
class CustomInputField extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;

  const CustomInputField({
    Key? key,
    required this.placeholder,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        filled: true,
        fillColor: const Color(0xFFF3E7E7),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Color(0xFF974E4E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF1B0E0E),
        fontSize: 16,
      ),
    );
  }
}
