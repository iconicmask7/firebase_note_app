import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../viewmodels/quote_viewmodel.dart';
import '../../widgets/theme_toggle_button.dart';
import 'widgets/note_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authViewModelProvider);
    final notesAsync = ref.watch(notesViewModelProvider);
    final quoteAsync = ref.watch(quoteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref, userAsync, isDark),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              // Quote of the day card
              _buildQuoteCard(context, quoteAsync, isDark),
              SizedBox(height: 20.h),
              // Section header with count badge
              _buildNotesHeader(context, notesAsync),
              SizedBox(height: 12.h),
              // Notes list
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    if (notes.isEmpty) return _buildEmptyState(context);
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return TweenAnimationBuilder<double>(
                          key: ValueKey(note.id),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 600)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: NoteCard(
                            note: note,
                            accentColor: AppTheme.noteAccents[index % AppTheme.noteAccents.length],
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/dashboard/note', extra: note);
                            },
                            onDelete: () => _showDeleteDialog(context, ref, note.id),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _buildErrorState(context, e.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue userAsync,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
            ),
          ),
          child: Center(
            child: userAsync.whenData((u) => u).valueOrNull != null
                ? Text(
                    (userAsync.valueOrNull?.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : const Icon(LucideIcons.user, color: Colors.white, size: 16),
          ),
        ),
      ),
      title: userAsync.when(
        data: (user) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.name.split(' ').first ?? 'User'} 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
            ),
            Text(
              'Your notes are waiting',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        loading: () => const Text('Loading...'),
        error: (_, __) => const Text('Notes'),
      ),
      actions: [
        const ThemeToggleButton(),
        SizedBox(width: 4.w),
        _LogoutButton(),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildQuoteCard(BuildContext context, AsyncValue<String> quoteAsync, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  const Color(0xFFEEEDFF),
                ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.penTool, color: AppTheme.primaryColor, size: 18.w),
          SizedBox(width: 10.w),
          Expanded(
            child: quoteAsync.when(
              data: (quote) => Text(
                quote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 13.sp,
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesHeader(BuildContext context, AsyncValue notesAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Notes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22.sp),
        ),
        notesAsync.when(
          data: (notes) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${notes.length} notes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(LucideIcons.fileText, size: 44.w, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
          ),
          SizedBox(height: 20.h),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to create your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.wifiOff, size: 48.w, color: AppTheme.accentColor.withValues(alpha: 0.6)),
          SizedBox(height: 16.h),
          Text('Could not load notes', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8.h),
          Text(
            'Working offline — cached notes shown',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return _AnimatedFAB(onTap: () {
      HapticFeedback.mediumImpact();
      context.push('/dashboard/note');
    });
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String noteId) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DeleteConfirmSheet(
        onConfirm: () {
          HapticFeedback.heavyImpact();
          ref.read(notesViewModelProvider.notifier).deleteNote(noteId);
        },
      ),
    );
  }
}

// ─── Logout Button with Confirmation ────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Logout',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            HapticFeedback.lightImpact();
            _showLogoutDialog(context, ref);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
            ),
            child: const Icon(LucideIcons.logOut, size: 18, color: AppTheme.accentColor),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LogoutConfirmSheet(
        onConfirm: () => ref.read(authViewModelProvider.notifier).signOut(),
      ),
    );
  }
}

// ─── Logout Confirmation Bottom Sheet ──────────────────────────────────────
class _LogoutConfirmSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogoutConfirmSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withValues(alpha: 0.1),
            ),
            child: Icon(LucideIcons.logOut, size: 32.w, color: AppTheme.accentColor),
          ),
          SizedBox(height: 20.h),
          Text(
            'Logging Out?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'You will be redirected to the login screen.\nYour notes are safely saved in the cloud.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shadowColor: AppTheme.accentColor.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: const Text('Yes, Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Delete Confirmation Bottom Sheet ──────────────────────────────────────
class _DeleteConfirmSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _DeleteConfirmSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentColor.withValues(alpha: 0.1),
            ),
            child: Icon(LucideIcons.trash2, size: 32.w, color: AppTheme.accentColor),
          ),
          SizedBox(height: 20.h),
          Text(
            'Delete Note?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'This action cannot be undone.\nThe note will be permanently removed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shadowColor: AppTheme.accentColor.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Animated FAB ────────────────────────────────────────────────────────────
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFAB({required this.onTap});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _rotation = Tween<double>(begin: 0.0, end: 0.25)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: child,
          ),
        ),
        child: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
