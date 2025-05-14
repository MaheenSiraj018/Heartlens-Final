import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/result_screen.dart';
import 'screens/user_input.dart';
import 'screens/upload_ecg_screen.dart';
import 'screens/homepage_screen.dart';
import 'screens/localization_screen.dart';
import 'blocs/user_data_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(  // Wrap MaterialApp with BlocProvider
      create: (context) => UserDataBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HeartLens',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const ResultScreen(),
          '/input': (context) => const UserInput(),
          '/home': (context) => HomePageScreen(),
          '/localization': (context) => const LocalizationScreen(),        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'screens/splash_screen.dart';
// import 'screens/main_screen.dart';
// import 'screens/result_screen.dart';
// import 'screens/user_input.dart';
// import 'screens/upload_ecg_screen.dart';
// import 'screens/homepage_screen.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'HeartLens',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       // Define the routes
//       routes: {
//         '/': (context) => const SplashScreen(), // Splash Screen as initial route
//         '/main': (context) => const ResultScreen(), // Main Screen
//         '/input' :(context) => const UserInput(),
//         '/home' : (context) =>  HomePageScreen(),
//       },
//     );
//   }
// }


// import 'package:flutter/material.dart';
//
// import 'screens/main_screen.dart';
// import 'screens/splash_screen.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'HeartLens',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }
//
