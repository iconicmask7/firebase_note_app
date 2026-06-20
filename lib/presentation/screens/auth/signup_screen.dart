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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final v = _passwordController.text;
    double strength = 0;
    if (v.length >= 6) strength += 0.25;
    if (v.length >= 10) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(v)) strength += 0.25;
    if (RegExp(r'[0-9!@#$%^&*]').hasMatch(v)) strength += 0.25;
    setState(() => _passwordStrength = strength);
  }

  Color get _strengthColor {
    if (_passwordStrength <= 0.25) return AppTheme.accentColor;
    if (_passwordStrength <= 0.5) return AppTheme.accentOrange;
    if (_passwordStrength <= 0.75) return AppTheme.accentGreen.withValues(alpha: 0.7);
    return AppTheme.accentGreen;
  }

  String get _strengthLabel {
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong 💪';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _signup() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).signUp(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authViewModelProvider, (_, next) {
      if (next is AsyncError) {
        HapticFeedback.heavyImpact();
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
              Positioned(top: 8.h, right: 16.w, child: const ThemeToggleButton()),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              _CircleBack(onTap: () {
                                HapticFeedback.lightImpact();
                                context.pop();
                              }),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Create\nAccount',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 38.sp,
                              height: 1.1,
                              letterSpacing: -1.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Join thousands organizing their thoughts',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
                          ),
                          SizedBox(height: 36.h),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(LucideIcons.user),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
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
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(LucideIcons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          // Password strength indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _passwordStrength),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, value, _) => LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _strengthLabel,
                                style: TextStyle(color: _strengthColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(LucideIcons.shieldCheck),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _obscureConfirm = !_obscureConfirm);
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          SizedBox(height: 32.h),
                          _TappableScaleButton(
                            onTap: authState.isLoading ? null : _signup,
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
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: const TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBack({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: const Icon(LucideIcons.arrowLeft, size: 20),
      ),
    );
  }
}

class _TappableScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TappableScaleButton({required this.child, this.onTap});

  @override
  State<_TappableScaleButton> createState() => _TappableScaleButtonState();
}

class _TappableScaleButtonState extends State<_TappableScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _ctrl.forward() : null,
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
