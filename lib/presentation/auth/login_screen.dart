import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../components/glass_card.dart';
import '../dashboard/home_screen.dart';
import '../../data/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _keyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final token = await ref.read(apiServiceProvider).login(
        _emailController.text,
        _keyController.text,
      );
      
      if (token != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Access Key')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Shader/Glow (Simulated)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.hint.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo
                  Center(
                    child: GlassCard(
                      borderRadius: 32,
                      width: 110,
                      height: 110,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Title
                  Text(
                    'STREET RIDE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    'FINANCE MANAGER',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Login Card
                  GlassCard(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to manage 14 members',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Email Input
                        _buildTextField(
                          controller: _emailController,
                          label: 'Organization Email',
                          hint: 'name@streetride.org',
                          icon: Icons.email_outlined,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Access Key Input
                        _buildTextField(
                          controller: _keyController,
                          label: 'Access Key',
                          hint: 'Enter secure key',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Key?',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sign In to Dashboard'),
                                  SizedBox(width: 8),
                                  Icon(Icons.login_rounded, size: 18),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.glassBorder)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.glassBorder)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton(Icons.g_mobiledata_rounded),
                      _socialButton(Icons.apple_rounded),
                      _socialButton(Icons.window_rounded),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Footer
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: 'Not a member yet? ',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Contact Admin',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'v2.4.0 Secure Audit Active',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0x8094A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.white54, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 70,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
