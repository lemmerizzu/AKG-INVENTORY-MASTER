import 'dart:async';
import 'package:flutter/services.dart';

/// A service that listens to global hardware keyboard events to capture
/// input from HID barcode scanners.
class ScannerService {
  final Function(String) onScan;
  final bool Function() isEnabled;
  
  String _buffer = '';
  Timer? _bufferTimer;

  ScannerService({required this.onScan, required this.isEnabled}) {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!isEnabled()) return false;
    if (event is! KeyDownEvent) return false;

    // Detect ENTER as suffix
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_buffer.isNotEmpty) {
        onScan(_buffer);
        _buffer = '';
      }
      return false;
    }

    // Append character if it's a printable key
    final character = event.character;
    if (character != null && character.isNotEmpty) {
      _buffer += character;
      
      // Reset timer - if typing is too slow, it's manual input, not a scanner
      _bufferTimer?.cancel();
      _bufferTimer = Timer(const Duration(milliseconds: 50), () {
        // Clear buffer if it's been idle too long (optional, 
        // some might prefer keeping it if scanners are slow)
        // _buffer = ''; 
      });
    }

    return false; // Let events propagate to other listeners if needed
  }

  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _bufferTimer?.cancel();
  }
}
