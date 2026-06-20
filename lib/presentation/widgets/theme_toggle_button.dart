import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    IconData icon;
    String tooltip;
    switch (themeMode) {
      case ThemeMode.dark:
        icon = LucideIcons.moon;
        tooltip = 'Dark Mode';
        break;
      case ThemeMode.light:
        icon = LucideIcons.sun;
        tooltip = 'Light Mode';
        break;
      case ThemeMode.system:
        icon = LucideIcons.monitor;
        tooltip = 'System Mode';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(themeNotifierProvider.notifier).toggle();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(icon, key: ValueKey(icon), size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
