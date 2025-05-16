import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user_health_bloc.dart';
import '../data/user_health_data.dart';
import '../events/user_health_event.dart';
import '../states/user_health_state.dart';

class HeartHealthScreen extends StatelessWidget {
  const HeartHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHealthBloc, UserHealthState>(
      builder: (context, state) {
        if (state is UserHealthLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Personalized Heart Health',style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),),
              backgroundColor: const Color(0xFFFFA2A2),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserHealthError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Personalized Heart Health',style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),),
              backgroundColor: const Color(0xFFFFA2A2),
            ),
            body: Center(child: Text(state.message)),
          );
        } else if (state is UserHealthLoaded) {
          return _buildLoadedScreen(context, state);
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Personalized Heart Health',style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),),
            backgroundColor: const Color(0xFFFFA2A2),
          ),
          body: const Center(child: Text('No data available')),
        );
      },
    );
  }

  Widget _buildLoadedScreen(BuildContext context, UserHealthLoaded state) {
    // Parse the Gemini response into sections
    final sections = _parseGeminiResponse(state.recommendations);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personalized Heart Health',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFA2A2),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi there,',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF932828),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generateWelcomeMessage(state.userData),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Display each section as a card
                if (sections['AVOID THESE'] != null)
                  _buildCard(
                    icon: Icons.block,
                    title: 'Foods to Avoid',
                    items: sections['AVOID THESE']!,
                    color: const Color(0xFF932828),
                  ),

                if (sections['EAT THESE INSTEAD'] != null)
                  _buildCard(
                    icon: Icons.restaurant,
                    title: 'Heart-Healthy Foods',
                    items: sections['EAT THESE INSTEAD']!,
                    color: const Color(0xFF932828),
                  ),

                if (sections['SIMPLE MEAL IDEAS'] != null)
                  _buildCard(
                    icon: Icons.fastfood,
                    title: 'Simple Meal Ideas',
                    items: sections['SIMPLE MEAL IDEAS']!,
                    color: const Color(0xFF932828),
                  ),
                if (sections['EXERCISES'] != null)
                  _buildCard(
                    icon: Icons.directions_run,
                    title: 'Recommended Exercises',
                    items: sections['EXERCISES']!,
                    color: const Color(0xFF932828),
                  ),
                if (sections['EXTRA TIPS'] != null)
                  _buildCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Pro Tips',
                    items: sections['EXTRA TIPS']!,
                    color: const Color(0xFF932828),
                  ),




                // Add more sections similarly...
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateWelcomeMessage(UserHealthData userData) {
    return "Based on your profile (age ${userData.age} and  ${userData.activity} activity level), "
        "here are personalized recommendations to improve your heart health. "
        "Your cholesterol level is ${userData.cholesterol} mg/dL.";
  }

  Map<String, List<String>> _parseGeminiResponse(String response) {
    final sections = <String, List<String>>{};
    final lines = response.split('\n');
    String currentSection = '';

    for (var line in lines) {
      if (line.startsWith('### ')) {
        currentSection = line.substring(4).trim();
        sections[currentSection] = [];
      } else if (currentSection.isNotEmpty && line.trim().isNotEmpty) {
        if (line.trim().startsWith('- ') || line.trim().startsWith('• ')) {
          sections[currentSection]!.add(line.trim().substring(2));
        } else {
          sections[currentSection]!.add(line.trim());
        }
      }
    }

    return sections;
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}