import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import 'ak_section_header.dart';

class AkFloatingWindow extends StatefulWidget {
  final String id;
  final String title;
  final Offset position;
  final Size size;
  final Widget child;
  final VoidCallback onClose;
  final VoidCallback? onFocus;
  final Function(Offset position)? onPositionChanged;
  final Function(Size size)? onSizeChanged;
  final List<String> tabs;
  final int activeTabIndex;
  final ValueChanged<int>? onTabChanged;

  const AkFloatingWindow({
    super.key,
    required this.id,
    required this.title,
    required this.position,
    required this.size,
    required this.child,
    required this.onClose,
    this.onFocus,
    this.onPositionChanged,
    this.onSizeChanged,
    this.tabs = const [],
    this.activeTabIndex = 0,
    this.onTabChanged,
  });

  @override
  State<AkFloatingWindow> createState() => _AkFloatingWindowState();
}

class _AkFloatingWindowState extends State<AkFloatingWindow> {
  late Offset _position;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _size = widget.size;
  }

  @override
  void didUpdateWidget(AkFloatingWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) _position = widget.position;
    if (oldWidget.size != widget.size) _size = widget.size;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxSize = Size(screenSize.width * 0.9, screenSize.height * 0.9);
    final minSize = const Size(400, 300);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: _size.width,
            height: _size.height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(color: AppColors.borderColor, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ── Window Header & Tabs ─────────────────────────────
                _buildHeader(),

                // ── Content ──────────────────────────────────────────
                Expanded(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: widget.child,
                  ),
                ),

                // ── Resize Handle ────────────────────────────────────
                _buildResizeHandle(minSize, maxSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position += details.delta;
              widget.onPositionChanged?.call(_position);
            });
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.panelBg,
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, 
                  size: 18, color: AppColors.googleBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AkIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onTap: widget.onClose,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (widget.tabs.isNotEmpty)
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.panelBg,
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor),
              ),
            ),
            child: Row(
              children: widget.tabs.asMap().entries.map((entry) {
                final isSelected = entry.key == widget.activeTabIndex;
                return _TabItem(
                  label: entry.value,
                  isSelected: isSelected,
                  onTap: () => widget.onTabChanged?.call(entry.key),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildResizeHandle(Size minSize, Size maxSize) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _size = Size(
            max(minSize.width, min(maxSize.width, _size.width + details.delta.dx)),
            max(minSize.height, min(maxSize.height, _size.height + details.delta.dy)),
          );
          widget.onSizeChanged?.call(_size);
        });
      },
      child: Container(
        height: 12,
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(2),
        child: const Icon(Icons.drag_handle_rounded, 
          size: 10, color: AppColors.textDisabled),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.googleBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.googleBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
