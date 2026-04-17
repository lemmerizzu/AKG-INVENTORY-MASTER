import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/print_server_service.dart';
import '../domain/print_job.dart';

final printServerServiceProvider = Provider<PrintServerService>((ref) {
  return PrintServerService();
});

final printQueueStreamProvider = StreamProvider<List<PrintJob>>((ref) {
  final service = ref.watch(printServerServiceProvider);
  return service.getPrintQueueStream();
});

class PrintServerNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Default: Server mode is OFF
  }

  void toggleServerMode(bool isActive) {
    state = isActive;
    // Note: In a real implementation, you might want to start/stop a dedicated 
    // background worker here to automatically process pending jobs.
    // For this prototype, we rely on the UI observing the stream.
  }
}

final printServerModeProvider = NotifierProvider<PrintServerNotifier, bool>(
  PrintServerNotifier.new,
);
