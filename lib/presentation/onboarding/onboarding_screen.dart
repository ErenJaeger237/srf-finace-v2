import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../components/glass_card.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _steps = [
    OnboardingData(
      title: 'Street Ride Finance',
      description: 'Managing organizational finances for the Street Ride crew with total transparency and precision.',
      icon: Icons.skateboarding_rounded,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: '14-Member Structure',
      description: '1 Manager + 13 Viewers for total audit control and financial integrity.',
      icon: Icons.group_rounded,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'Excel Export',
      description: 'Generate professional audit trails and financial reports instantly with one tap.',
      icon: Icons.description_rounded,
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.background.withBlue(20),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.speed_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'STREET RIDE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon/Animation Placeholder
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: step.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(step.icon, size: 100, color: step.color),
                            ),
                            const SizedBox(height: 60),
                            Text(
                              step.title,
                              textAlign: Center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              step.description,
                              textAlign: Center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Controls
                GlassCard(
                  borderRadius: 0,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Progress Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.primary : Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _finishOnboarding(context),
                              child: const Text('Skip', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage < _steps.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _finishOnboarding(context);
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_currentPage == _steps.length - 1 ? 'Get Started' : 'Continue'),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
