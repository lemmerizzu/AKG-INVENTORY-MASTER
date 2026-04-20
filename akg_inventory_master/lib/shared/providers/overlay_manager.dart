import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayWindow {
  final String id;
  final String title;
  final Offset position;
  final Size size;
  final DateTime createdAt;
  final bool isMinimized;

  OverlayWindow({
    required this.id,
    required this.title,
    this.position = const Offset(100, 100),
    this.size = const Size(800, 600),
    this.isMinimized = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  OverlayWindow copyWith({
    String? title,
    Offset? position,
    Size? size,
    bool? isMinimized,
  }) {
    return OverlayWindow(
      id: id,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      isMinimized: isMinimized ?? this.isMinimized,
      createdAt: createdAt,
    );
  }
}

class OverlayManager extends Notifier<List<OverlayWindow>> {
  @override
  List<OverlayWindow> build() => [];

  void open(String id, String title, {Offset? position}) {
    // Bring to front if already open
    final existingIndex = state.indexWhere((w) => w.id == id);
    if (existingIndex != -1) {
      final window = state[existingIndex];
      state = [
        ...state.where((w) => w.id != id),
        window.copyWith(isMinimized: false),
      ];
      return;
    }

    // Otherwise add new
    final newWindow = OverlayWindow(
      id: id,
      title: title,
      position: position ?? Offset(100 + (state.length * 30), 100 + (state.length * 30)),
    );
    state = [...state, newWindow];
  }

  void close(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void updateWindow(String id, {Offset? position, Size? size, bool? isMinimized}) {
    state = [
      for (final w in state)
        if (w.id == id)
          w.copyWith(position: position, size: size, isMinimized: isMinimized)
        else
          w
    ];
  }

  void bringToFront(String id) {
    final window = state.firstWhere((w) => w.id == id);
    state = [...state.where((w) => w.id != id), window];
  }
}

final overlayManagerProvider =
    NotifierProvider<OverlayManager, List<OverlayWindow>>(OverlayManager.new);
