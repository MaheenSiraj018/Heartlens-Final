import 'package:flutter/material.dart';
import 'upload_ecg_screen.dart';

class HomePageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main Heading
            SizedBox(height:25),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: 'Welcome to '),
                  TextSpan(
                    text: 'HeartLens',
                    style: TextStyle(
                        color: Color(0xFFD23939) // Red color for HeartLens
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // First Card
            _buildCard(
              context,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/home1.jpg', // Replace with your image path
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enhance Your Heart Health!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color updated to black
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover benefits of ECG analysis',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                      Color(0xff827979), // Standard grey for secondary text
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Second Card
            _buildCard(
              context,
              child: Column(
                children: [
                  const Text(
                    'Why use HeartLens?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color updated to black
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Organizing feature cards in rows
                  Column(
                    children: [
                      // First Row of Feature Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _featureCard(Icons.favorite, 'Easy STEMI Detection'),
                          _featureCard(
                              Icons.monitor_heart, 'Effortless ECG Analysis'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Second Row of Feature Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _featureCard(Icons.shield, 'Secure & Trustworthy'),
                          _featureCard(Icons.description,
                              'Detailed Reports for Insights'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Third Card
            _buildCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Who can use HeartLens?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color updated to black
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, size: 40, color: Color(0xFFD23939)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cardiologists: Analyze ECGs effectively and gain insights to support diagnosis.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black, // Text color updated to black
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.health_and_safety,
                          size: 40, color: Color(0xFFD23939)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Patients: Stay informed about your heart health with an easy-to-use platform.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black, // Text color updated to black
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Perform ECG Analysis Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Leave this empty for now
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadECGScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD23939),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Upload ECG for Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create reusable cards with consistent size
  Widget _buildCard(BuildContext context, {required Widget child}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(1), // Transparent white with some opacity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth:
          screenWidth > 600 ? 600 : screenWidth - 32, // Responsive width
        ),
        decoration: BoxDecoration(
          color:
          Color(0xfffff1f1), // Set pure white background without any tint
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }

  // Helper method to create feature cards
  Widget _featureCard(IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xfff2b0b0), // Slightly lighter shade
            radius: 28,
            child: Icon(icon, size: 28, color: const Color(0xFFD23939)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black, // Text color updated to black
            ),
          ),
        ],
      ),
    );
  }
}