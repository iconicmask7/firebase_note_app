import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.8,
          colors: isDark
              ? [
                  const Color(0xFF1A1040),
                  AppTheme.darkBackground,
                  const Color(0xFF0A0A18),
                ]
              : [
                  const Color(0xFFEEEDFF),
                  AppTheme.lightBackground,
                  const Color(0xFFE8F5FF),
                ],
        ),
      ),
      child: child,
    );
  }
}
