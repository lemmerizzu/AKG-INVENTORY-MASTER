import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../domain/print_job.dart';
import 'print_server_provider.dart';

class SelectedJobNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedPrintJobIdProvider = NotifierProvider<SelectedJobNotifier, String?>(SelectedJobNotifier.new);

class PrintServerView extends ConsumerWidget {
  const PrintServerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(printQueueStreamProvider);
    final isServerActive = ref.watch(printServerModeProvider);
    final selectedJobId = ref.watch(selectedPrintJobIdProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Cetak Dokumen & Print Server',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(
                isServerActive ? 'Print Server: ACTIVE' : 'Print Server: INACTIVE',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isServerActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isServerActive,
                activeThumbColor: Colors.green,
                onChanged: (val) {
                  ref.read(printServerModeProvider.notifier).toggleServerMode(val);
                },
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: Row(
        children: [
          // Left Pane: Queue List
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
              ),
              child: queueAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print_disabled, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('Antrian Kosong',
                              style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final isSelected = job.id == selectedJobId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        leading: _buildStatusIcon(job.status),
                        title: Text(
                          job.documentType,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          'Requested: ${job.createdAt != null ? DateFormat('dd MMM yyyy HH:mm').format(job.createdAt!) : '-'}',
                          style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 11),
                        ),
                        trailing: _buildStatusBadge(job.status),
                        onTap: () {
                          ref.read(selectedPrintJobIdProvider.notifier).select(job.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Right Pane: Details & Actions
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.background,
              child: _buildRightPane(context, ref, queueAsync, selectedJobId, isServerActive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(BuildContext context, WidgetRef ref, AsyncValue<List<PrintJob>> queueAsync, String? selectedJobId, bool isServerActive) {
    if (selectedJobId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Pilih dokumen dari antrian',
                style: GoogleFonts.inter(color: AppTheme.textLight)),
          ],
        ),
      );
    }

    final jobs = queueAsync.value ?? [];
    final jobIndex = jobs.indexWhere((j) => j.id == selectedJobId);
    
    if (jobIndex == -1) {
      return const Center(child: Text('Dokumen tidak ditemukan'));
    }

    final job = jobs[jobIndex];
    final service = ref.read(printServerServiceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Dokumen',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                _buildStatusBadge(job.status),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Job ID', job.id),
            _buildDetailRow('Tipe Dokumen', job.documentType),
            _buildDetailRow('Reference ID', job.referenceId ?? '-'),
            _buildDetailRow('File Path / Name', job.filePath),
            _buildDetailRow('Waktu Request', job.createdAt != null ? DateFormat('dd MMM yyyy, HH:mm:ss').format(job.createdAt!) : '-'),
            if (job.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(job.errorMessage!, style: GoogleFonts.inter(color: AppTheme.error, fontSize: 13))),
                  ],
                ),
              )
            ],
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (job.status == PrintStatus.pending && isServerActive) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Batalkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      service.updateJobStatus(job.id, PrintStatus.failed, errorMessage: 'Dibatalkan oleh operator');
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print Sekarang'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      service.processJob(job);
                    },
                  ),
                ],
                if (job.status == PrintStatus.completed) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Tandai Valid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dokumen ditandai valid dan diarsipkan.')),
                      );
                    },
                  ),
                ],
                if (job.status == PrintStatus.failed) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Coba Lagi (Retry)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      service.updateJobStatus(job.id, PrintStatus.pending);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, color: AppTheme.textLight, fontSize: 13)),
          ),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PrintStatus status) {
    final (label, color) = switch (status) {
      PrintStatus.pending => ('PENDING', Colors.orange),
      PrintStatus.printing => ('PRINTING', AppTheme.primaryBlue),
      PrintStatus.completed => ('COMPLETED', const Color(0xFF00C853)),
      PrintStatus.failed => ('FAILED', AppTheme.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }


  Icon _buildStatusIcon(PrintStatus status) {
    return switch (status) {
      PrintStatus.pending => const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
      PrintStatus.printing => Icon(Icons.print, color: AppTheme.primaryBlue, size: 20),
      PrintStatus.completed => const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 20),
      PrintStatus.failed => const Icon(Icons.error, color: AppTheme.error, size: 20),
    };
  }
}
