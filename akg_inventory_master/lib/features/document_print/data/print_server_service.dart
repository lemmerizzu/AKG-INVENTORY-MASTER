import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import '../domain/print_job.dart';

class PrintServerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'print_queue';
  static const String _bucketName = 'print_spool';

  /// Stream to listen to real-time changes in the print queue.
  /// Typically, the server mode will listen to this stream.
  Stream<List<PrintJob>> getPrintQueueStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((m) => PrintJob.fromJson(m)).toList());
  }

  /// Only listen to PENDING jobs (useful for background worker)
  Stream<List<PrintJob>> getPendingJobsStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('status', PrintStatus.pending.value)
        .order('created_at', ascending: true)
        .map((maps) => maps.map((m) => PrintJob.fromJson(m)).toList());
  }

  /// Client method: Submit a PDF document for printing
  Future<void> submitPrintJob({
    required String documentType,
    required Uint8List pdfData,
    String? referenceId,
  }) async {
    final fileName = '${documentType}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    // 1. Upload PDF to storage
    await _supabase.storage.from(_bucketName).uploadBinary(
          fileName,
          pdfData,
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );

    // 2. Insert into queue
    await _supabase.from(_tableName).insert({
      'document_type': documentType,
      'reference_id': referenceId,
      'file_path': fileName, // Store the filename/path
      'status': PrintStatus.pending.value,
      'requested_by': _supabase.auth.currentUser?.id,
    });
  }

  /// Server method: Update the status of a job
  Future<void> updateJobStatus(String id, PrintStatus status, {String? errorMessage}) async {
    final updateData = <String, dynamic>{
      'status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (errorMessage != null) {
      updateData['error_message'] = errorMessage;
    }
    await _supabase.from(_tableName).update(updateData).eq('id', id);
  }

  /// Server method: Download PDF and print using system printer
  Future<void> processJob(PrintJob job) async {
    try {
      // Mark as printing
      await updateJobStatus(job.id, PrintStatus.printing);

      // Download PDF binary
      final pdfBytes = await _supabase.storage
          .from(_bucketName)
          .download(job.filePath);

      // Execute native printing
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'JOB_${job.documentType}_${job.id.substring(0, 8)}',
      );

      // We might not immediately mark as COMPLETED here if we want the 
      // operator to visually verify. But usually, sending to spooler means done.
      // We will mark it completed for now. The user can manually 'mark valid' later.
      await updateJobStatus(job.id, PrintStatus.completed);

    } catch (e) {
      await updateJobStatus(
        job.id, 
        PrintStatus.failed, 
        errorMessage: e.toString(),
      );
    }
  }

  /// Fetch all available printers on this server machine
  Future<List<Printer>> getAvailablePrinters() async {
    return await Printing.info().then((info) => info.canPrint ? Printing.listPrinters() : []);
  }
}
