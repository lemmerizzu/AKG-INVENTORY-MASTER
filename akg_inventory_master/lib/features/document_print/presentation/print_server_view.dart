import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Cetak Dokumen & Print Server'),
        actions: [
          Row(
            children: [
              Text(
                isServerActive ? 'Print Server: ACTIVE' : 'Print Server: INACTIVE',
                style: TextStyle(
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
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: queueAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const Center(child: Text('Antrian Kosong'));
                  }
                  return ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final isSelected = job.id == selectedJobId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        leading: _buildStatusIcon(job.status),
                        title: Text(
                          job.documentType,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Requested: ${job.createdAt != null ? DateFormat('dd MMM yyyy HH:mm').format(job.createdAt!) : '-'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        trailing: Text(
                          job.status.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(job.status),
                          ),
                        ),
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
      return const Center(child: Text('Pilih dokumen dari antrian'));
    }

    final jobs = queueAsync.value ?? [];
    final jobIndex = jobs.indexWhere((j) => j.id == selectedJobId);
    
    if (jobIndex == -1) {
      return const Center(child: Text('Dokumen tidak ditemukan'));
    }

    final job = jobs[jobIndex];
    final service = ref.read(printServerServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Dokumen',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job.status.value,
                      style: TextStyle(color: _getStatusColor(job.status), fontWeight: FontWeight.bold),
                    ),
                  )
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(job.errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                )
              ],
              const Spacer(),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (job.status == PrintStatus.pending && isServerActive) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        service.updateJobStatus(job.id, PrintStatus.failed, errorMessage: 'Dibatalkan oleh operator');
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('Print Sekarang'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                      onPressed: () {
                        service.processJob(job);
                      },
                    ),
                  ],
                  if (job.status == PrintStatus.completed) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Tandai Valid'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dokumen ditandai valid dan diarsipkan.')),
                        );
                        // Implementasi archive logika
                      },
                    ),
                  ],
                  if (job.status == PrintStatus.failed) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi (Retry)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        service.updateJobStatus(job.id, PrintStatus.pending);
                      },
                    ),
                  ],
               ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(PrintStatus status) {
    switch (status) {
      case PrintStatus.pending:
        return Colors.orange;
      case PrintStatus.printing:
        return Colors.blue;
      case PrintStatus.completed:
        return Colors.green;
      case PrintStatus.failed:
        return Colors.red;
    }
  }

  Icon _buildStatusIcon(PrintStatus status) {
    switch (status) {
      case PrintStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case PrintStatus.printing:
        return const Icon(Icons.print, color: Colors.blue);
      case PrintStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PrintStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
