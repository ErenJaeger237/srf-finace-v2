import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Add simple error handling for platform-specific initialization
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('SRFM Error: ${details.exception}');
    };

    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('show_onboarding') ?? true;
    
    runApp(
      ProviderScope(
        child: StreetRideApp(showOnboarding: showOnboarding),
      ),
    );
  } catch (e, stack) {
    debugPrint('SRFM Fatal Startup Error: $e');
    debugPrint(stack.toString());
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
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
