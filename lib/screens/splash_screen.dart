import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _logoAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Slide-up animation
    _logoAnimation = Tween<Offset>(
      begin: const Offset(0, 2), // Start below the screen
      end: Offset.zero, // End at its normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start the animation
    _animationController.forward();

    // Navigate to MainScreen after 10 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                //0xFFFFD1D1 0xFF932828 FFFFA2A2
                colors: [Color(0xFFFFA2A2), Color(0xFFFFD1D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Logo and loading dots
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo
                SlideTransition(
                  position: _logoAnimation,
                  child: Image.asset(
                    'assets/images/HeartLens_logowithoutbg.png', // Replace with your logo file path
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 20),
                // Loading dots
                const LoadingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A widget for animated loading dots
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> {
  int _dotIndex = 0;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();

    // Delay dots animation until logo animation finishes
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _shouldAnimate = true;
      });

      // Start updating dot index every 500ms
      if (_shouldAnimate) {
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
          if (!mounted) {
            timer.cancel();
          } else {
            setState(() {
              _dotIndex = (_dotIndex + 1) % 3;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show dots only when animation is ready
    return _shouldAnimate
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _dotIndex == index
                ? Colors.grey.shade800
                : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    )
        : const SizedBox.shrink(); // Show nothing until animation starts
  }
}