import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('show_onboarding') ?? true;
  
  runApp(
    ProviderScope(
      child: StreetRideApp(showOnboarding: showOnboarding),
    ),
  );
}

class StreetRideApp extends StatelessWidget {
  final bool showOnboarding;
  const StreetRideApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Street Ride Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const LoginScreen(),
    );
  }
}
