import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/user_health_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../events/user_health_event.dart';
import '../states/user_health_state.dart';

class UserHealthBloc extends Bloc<UserHealthEvent, UserHealthState> {
  UserHealthBloc() : super(UserHealthInitial()) {
    on<UpdateUserHealthData>(_onUpdateUserHealthData);
  }

  Future<void> _onUpdateUserHealthData(
      UpdateUserHealthData event,
      Emitter<UserHealthState> emit,
      ) async {
    emit(UserHealthLoading());

    try {
      // Initialize the model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: dotenv.env['GEMINI_API_KEY']!,  // Directly use .env
      );

      // Build the prompt
      final prompt = _buildPrompt(event.userData);

      // Generate content
      final response = await model.generateContent([Content.text(prompt)]);

      final cleanResponse = _removeLeadingAsterisks(response.text ?? '');

      emit(UserHealthLoaded(
        userData: event.userData,
        recommendations: cleanResponse,
      ));

    } catch (e) {
      emit(UserHealthError('Failed to generate recommendations: ${e.toString()}'));
    }
  }

  String _buildPrompt(UserHealthData data) {
    return """
**ROLE**: You are a **cardiac health specialist** giving personalized advice to a patient.
**TONE**: Simple, empathetic, and direct. Avoid medical jargon.
**OUTPUT RULES**:
  - NEVER use markdown (*, _, #, etc.)
  - Make sure first word is a letter rather than a markdown or *
  - ONLY use plain text
  - ALSO Use bullets or sterics for each just give different items in next lines

**USER PROFILE**:
- Age: ${data.age}
- Cholesterol: ${data.cholesterol} mg/dL
- Smoker: ${data.smoker}
- Activity Level: ${data.activity}
- Weight: ${data.weightStatus}
- Conditions: ${data.conditions}

**TASK**: Provide a personalized heart-health plan with:

### AVOID THESE (Be Specific!)
- List 3-5 exact foods in bullet form they should cut.

### EAT THESE INSTEAD
- Give 5-7 specific foods (e.g., "oats for soluble fiber").

### SIMPLE MEAL IDEAS
- Include simple meal ideas for breakfast, lunch and dinner.

### EXERCISES
- Suggest appropriate exercises based on age and activity level.

### EXTRA TIPS
- Include 1 cholesterol hack and 1 stress-reduction tip.

**OUTPUT FORMAT**: Use bullet points, avoid long paragraphs. Start each section with "### SECTION_TITLE" exactly as written above.
""";
  }
  String _removeLeadingAsterisks(String text) {
    return text.replaceAll(RegExp(r'^\*', multiLine: true), '');
  }
}