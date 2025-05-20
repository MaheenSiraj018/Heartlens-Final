import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:report_heartlens/blocs/user_health_bloc.dart';
import 'package:report_heartlens/screens/heart_health_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/result_screen.dart';
import 'screens/user_input.dart';
import 'screens/upload_ecg_screen.dart';
import 'screens/homepage_screen.dart';
import 'screens/localization_screen.dart';
import 'screens/personalization_input.dart';
import 'blocs/user_data_bloc.dart';
import 'blocs/user_image_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'blocs/report_generator_bloc.dart';
import 'blocs/model_output_bloc.dart';

void main() async {
  await dotenv.load(fileName: ".env");  // Explicit filename
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(  // Wrap MaterialApp with BlocProvider
      providers: [
        BlocProvider<UserDataBloc>(
          create: (context) => UserDataBloc(),
        ),
        BlocProvider<UserImageBloc>(
          create: (context) => UserImageBloc(),
        ),
        BlocProvider<UserHealthBloc>(
          create: (context) =>UserHealthBloc(),
        ),
        BlocProvider<ReportGeneratorBloc>(
          create: (context) =>ReportGeneratorBloc(),
        ),
        BlocProvider<ModelOutputBloc>(
          create: (context) => ModelOutputBloc(),
        ),

      ],      child: MaterialApp(
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
          '/localization': (context) {
            // Get the arguments passed when navigating to this route
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return LocalizationScreen(
              miType: args?['miType'] ?? '', // Use the passed MI type or empty string
            );
          },          '/personalization_input' : (context) => const PersonalizationInputScreen(),
          '/hearthealth' : (context) => const HeartHealthScreen()
        },
      ),
    );
  }
}
