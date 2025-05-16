// lib/screens/personalization_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user_health_bloc.dart';
import '../data/user_health_data.dart';
import '../events/user_health_event.dart';

class PersonalizationInputScreen extends StatefulWidget {
  const PersonalizationInputScreen({Key? key}) : super(key: key);

  @override
  State<PersonalizationInputScreen> createState() => _PersonalizationInputScreenState();
}

class _PersonalizationInputScreenState extends State<PersonalizationInputScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();

  String smoker = 'No';
  String activity = 'sedentary';
  String weightStatus = 'normal';

  // In _PersonalizationInputScreenState
  void _submitData() {
    final userData = UserHealthData(
      age: int.tryParse(ageController.text) ?? 0,
      cholesterol: int.tryParse(cholesterolController.text) ?? 0,
      smoker: smoker,
      activity: activity.toLowerCase(),  // Ensure case matches
      weightStatus: weightStatus.toLowerCase(),
      conditions: conditionsController.text,
    );

    // This must match your event class name exactly
    context.read<UserHealthBloc>().add(UpdateUserHealthData(userData));
    Navigator.pushNamed(context, '/hearthealth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Health Input', style: TextStyle(
          color: Color(0xFF1B0E0E),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: const Color(0xFFFFD1D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0E0E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNumberField('Age', ageController),
              const SizedBox(height: 16),
              _buildNumberField('Cholesterol (mg/dL)', cholesterolController),
              const SizedBox(height: 16),
              _buildDropdownField('Smoker', ['Yes', 'No'], (value) => smoker = value ?? 'No'),
              const SizedBox(height: 16),
              _buildDropdownField('Activity Level', ['Sedentary', 'Light', 'Moderate', 'Active'], (value) => activity = value ?? 'sedentary'),
              const SizedBox(height: 16),
              _buildDropdownField('Weight Status', ['Underweight', 'Normal', 'Overweight', 'Obese'], (value) => weightStatus = value ?? 'normal'),
              const SizedBox(height: 16),
              _buildTextField('Any Recent Heart or Health Conditions', conditionsController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD23939),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: const Color(0xFFF3E7E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3E7E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      hint: Text(label, style: const TextStyle(color: Color(0xFF974E4E))),
      items: options.map((String option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: const Color(0xFFF3E7E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
