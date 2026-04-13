import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/database_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.ui('AuditLogScreen', 'BUILD');
    final db = ref.watch(databaseProvider);
    final logsAsync = ref.watch(
      StreamProvider<List<AuditLog>>((ref) {
        return (db.select(db.auditLogs)..orderBy([
              (a) => OrderingTerm(
                expression: a.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .watch();
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Journal d\'audit')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Aucune entrée'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogCard(context, log);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, AuditLog log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.action,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDateTime(log.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Table: ${log.tblName}'),
            if (log.recordId != null) Text('ID: ${log.recordId}'),
            if (log.oldData != null)
              Text(
                'Ancien: ${log.oldData}',
                style: TextStyle(color: Colors.red[700], fontSize: 12),
              ),
            if (log.newData != null)
              Text(
                'Nouveau: ${log.newData}',
                style: TextStyle(color: Colors.green[700], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
