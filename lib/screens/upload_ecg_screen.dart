import 'package:flutter/material.dart';
import '../example_ecgs.dart'; // Correct import path
import 'dart:io';

class UploadECGScreen extends StatefulWidget {
  @override
  _UploadECGScreenState createState() => _UploadECGScreenState();
}

class _UploadECGScreenState extends State<UploadECGScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  File? _selectedImage; // Placeholder for the selected image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.white, // Match your theme's color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Title and Pagination Dots
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex == 0
                        ? 'Guidelines for ECG Upload'
                        : 'Upload ECG',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                          (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Color(0xFF932828)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  // Guidelines Screen
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To ensure the highest quality analysis, please follow these guidelines:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),

                        // Bullet Points
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoint(
                                'Ensure the image is in color and high resolution.'),
                            _buildBulletPoint(
                                'Include the entire ECG graph in the image.'),
                            _buildBulletPoint(
                                'Avoid blurry or distorted images.'),
                            _buildBulletPoint(
                                'Make sure the ECG waveform is complete and not cut off.'),
                            _buildBulletPoint(
                                'It should be a 12-lead ECG for analysis.'),
                            _buildBulletPoint(
                                'Images should be in PNG, JPEG, or JPG formats.'),
                            _buildBulletPoint(
                                'Keep the file size under 5 MB for easy upload.'),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Image Previews (Placed above the button)
                        Column(
                          children: [
                            _buildImagePreview('assets/ecg1.png'),
                            SizedBox(height: 10),
                            _buildImagePreview('assets/ecg5.png'),
                            SizedBox(height: 10),
                            _buildImagePreview('assets/ecg3.jpg'),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Updated Button
                        Container(
                          width: double.infinity, // Full width
                          margin:
                          EdgeInsets.symmetric(horizontal: 16), // Spacing
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.01), // Shadow color
                                spreadRadius: 0.5,
                                blurRadius: 1,
                                offset: Offset(0, 3), // Offset
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExampleGalleryScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF932828), // Light red
                              padding:
                              EdgeInsets.symmetric(vertical: 10), // Padding
                            ),
                            child: Text(
                              'View Example Gallery',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Upload ECG Screen
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image from assets (placed under heading and pagination dots)
                        Image.asset(
                          'assets/top4.png', // Example asset image
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20),

                        // Upload and Take Photo Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _placeholderPickImage(), // Placeholder method
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF932828),
                              ),
                              child: Text(
                                'Choose Photo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _placeholderPickImage(), // Placeholder method
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF932828),
                              ),
                              child: Text(
                                'Take Photo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Placeholder for selected image (appears after buttons)
                        _selectedImage != null
                            ? Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          alignment: Alignment.center,
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(),
                        // Add this SizedBox for spacing
                        SizedBox(height: 20),

                        // Proceed to Analysis Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your navigation or action here
                              Navigator.pushReplacementNamed(context, '/main');
                              print('Proceed to Analysis button pressed');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Color(0xffe13232), // Red background
                              padding: EdgeInsets.symmetric(
                                  vertical: 15), // Button height
                            ),
                            child: Text(
                              'Proceed to Analysis',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16), // White text
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create bullet points with red bullets
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Fixed alignment issue
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: Color(0xFF932828), // Red bullets
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to display image preview
  Widget _buildImagePreview(String assetPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImagePage(imagePath: assetPath),
          ),
        );
      },
      child: Container(
        height: 100,
        width: double.infinity, // Full width
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Placeholder for image picker functionality
  Future<void> _placeholderPickImage() async {
    print('Image picker functionality is temporarily disabled.');
  }
}

class ExampleGalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example ECG Gallery'),
        backgroundColor: Color(0xFFFFD1D1),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: exampleECGImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenImagePage(imagePath: exampleECGImages[index]),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(exampleECGImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  FullScreenImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoomed Image'),
        backgroundColor: Color(0xFFFFA2A2),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}