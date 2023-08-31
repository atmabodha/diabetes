// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your custom classes and screens
import 'Providers/UserInfo.dart';
import 'Screens/Patient/GraphsScreen.dart';
import 'Screens/Doctor/HomeScreenD.dart';
import 'Screens/OnBoarding/SignInPage.dart';
import 'Screens/Patient/HomeScreenP.dart';

// Declare variables to store onboarding and user type information
late bool onboardingCompleted;
late bool isDoctor;

// Asynchronous function to set up and initialize the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences to retrieve saved data
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve onboarding and user type information from SharedPreferences
  onboardingCompleted = await prefs.getBool('onboardingCompleted') ?? false;
  isDoctor = await prefs.getBool('isDoctor') ?? false;

  // Run the app
  runApp(MyApp());
}

// Main app class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide UserProvider using ChangeNotifierProvider
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: onboardingCompleted
            ? isDoctor
            ? HomeScreenD() // If onboarding is completed and user is a doctor, show Doctor's home screen
            : HomeScreenP() // If onboarding is completed and user is not a doctor, show Patient's home screen
            : SignInPage(), // If onboarding is not completed, show the sign-in page
      ),
    );
  }
}
