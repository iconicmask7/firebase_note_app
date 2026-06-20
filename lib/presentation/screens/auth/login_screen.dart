import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/animated_gradient_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late AnimationController _entranceController;
  late AnimationController _shakeController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_shakeController);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _login() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authViewModelProvider, (previous, next) {
      if (next is AsyncError) {
        HapticFeedback.heavyImpact();
        _triggerShake();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(next.error.toString())),
            ]),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    });

    return Scaffold(
      body: AnimatedGradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: Stack(
            children: [
              // Theme toggle button in top-right
              Positioned(
                top: 8.h,
                right: 16.w,
                child: const ThemeToggleButton(),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (context, child) {
                          final dx = _shakeController.isAnimating
                              ? 12 * (0.5 - (_shakeAnim.value % 0.1) / 0.1).abs()
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: child,
                          );
                        },
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Animated Logo
                              AnimatedBuilder(
                                animation: _glowAnim,
                                builder: (context, child) {
                                  return Container(
                                    width: 100.w,
                                    height: 100.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withValues(alpha: _glowAnim.value * 0.6),
                                          blurRadius: 30 * _glowAnim.value,
                                          spreadRadius: 5 * _glowAnim.value,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 90.w,
                                  height: 90.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(LucideIcons.penTool, size: 40.w, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 32.h),
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 36.sp,
                                  letterSpacing: -1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Sign in to continue',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 44.h),
                              // Email Field
                              _buildAnimatedField(
                                delay: 0,
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(LucideIcons.mail),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    if (!v.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Password Field
                              _buildAnimatedField(
                                delay: 100,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(LucideIcons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  onFieldSubmitted: (_) => _login(),
                                ),
                              ),
                              SizedBox(height: 28.h),
                              // Login Button
                              _TappableButton(
                                onTap: authState.isLoading ? null : _login,
                                child: Container(
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: authState.isLoading
                                        ? null
                                        : const LinearGradient(
                                            colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
                                          ),
                                    color: authState.isLoading
                                        ? AppTheme.primaryColor.withValues(alpha: 0.4)
                                        : null,
                                    boxShadow: authState.isLoading
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                  ),
                                  alignment: Alignment.center,
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: GoogleFontsHelper.outfit(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                                    child: Text(
                                      'or',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              // Google Button
                              _TappableButton(
                                onTap: authState.isLoading
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        ref.read(authViewModelProvider.notifier).signInWithGoogle();
                                      },
                                child: Container(
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                    color: isDark
                                        ? AppTheme.primaryColor.withValues(alpha: 0.08)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LucideIcons.chrome, size: 20),
                                      SizedBox(width: 10.w),
                                      Text(
                                        'Continue with Google',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 28.h),
                              TextButton(
                                onPressed: () => context.push('/signup'),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

// Lightweight helper to avoid importing google_fonts everywhere
class GoogleFontsHelper {
  static TextStyle outfit({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Outfit',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

// Tappable widget with scale feedback
class _TappableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TappableButton({required this.child, this.onTap});

  @override
  State<_TappableButton> createState() => _TappableButtonState();
}

class _TappableButtonState extends State<_TappableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
