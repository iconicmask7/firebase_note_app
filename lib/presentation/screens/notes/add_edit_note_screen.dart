import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/note.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/theme_toggle_button.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final Note? note;
  const AddEditNoteScreen({super.key, this.note});

  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _saveAnim;
  late Animation<double> _saveScale;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController = TextEditingController(text: widget.note?.description ?? '');
    _titleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));

    _saveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _saveScale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _saveAnim, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _saveAnim.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    if (_formKey.currentState!.validate()) {
      await _saveAnim.forward();
      setState(() => _saved = true);
      await Future.delayed(const Duration(milliseconds: 300));

      if (widget.note == null) {
        ref.read(notesViewModelProvider.notifier).addNote(
              _titleController.text.trim(),
              _descriptionController.text.trim(),
            );
      } else {
        ref.read(notesViewModelProvider.notifier).updateNote(
              widget.note!,
              _titleController.text.trim(),
              _descriptionController.text.trim(),
            );
      }
      if (mounted) context.pop();
    }
  }

  int get _wordCount =>
      _descriptionController.text.trim().isEmpty
          ? 0
          : _descriptionController.text.trim().split(RegExp(r'\s+')).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: const Icon(LucideIcons.arrowLeft, size: 20),
          ),
        ),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
        ),
        actions: [
          const ThemeToggleButton(),
          SizedBox(width: 8.w),
          // Save FAB in AppBar
          GestureDetector(
            onTapDown: (_) => _saveAnim.forward(),
            onTapUp: (_) {
              _saveAnim.reverse();
              _save();
            },
            onTapCancel: () => _saveAnim.reverse(),
            child: AnimatedBuilder(
              animation: _saveScale,
              builder: (_, child) => Transform.scale(scale: _saveScale.value, child: child),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF9D97FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _saved
                      ? Row(
                          key: const ValueKey('saved'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.check, color: Colors.white, size: 16),
                            SizedBox(width: 4.w),
                            const Text('Saved!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        )
                      : Row(
                          key: const ValueKey('save'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.save, color: Colors.white, size: 16),
                            SizedBox(width: 4.w),
                            const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // If editing, show last edited time
          if (isEditing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
              child: Row(
                children: [
                  Icon(LucideIcons.clock, size: 12.w, color: Theme.of(context).textTheme.bodySmall?.color),
                  SizedBox(width: 4.w),
                  Text(
                    'Last edited: ${DateFormat('MMM dd, yyyy · hh:mm a').format(widget.note!.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                  ),
                ],
              ),
            ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
          Expanded(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        autofocus: widget.note == null,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Title is mandatory' : null,
                      ),
                      SizedBox(height: 4.h),
                      Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: TextFormField(
                          controller: _descriptionController,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp,
                            height: 1.7,
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Start writing something amazing...',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Word/character counter bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.type, size: 14.w, color: Theme.of(context).textTheme.bodySmall?.color),
                    SizedBox(width: 6.w),
                    Text(
                      '$_wordCount words',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(width: 16.w),
                    Icon(LucideIcons.hash, size: 14.w, color: Theme.of(context).textTheme.bodySmall?.color),
                    SizedBox(width: 6.w),
                    Text(
                      '${_descriptionController.text.length} chars',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _titleController.text.isNotEmpty
                      ? Text(
                          'Ready to save',
                          key: const ValueKey('ready'),
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          'Add a title first',
                          key: const ValueKey('empty'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
