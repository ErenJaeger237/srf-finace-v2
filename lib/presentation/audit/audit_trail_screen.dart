import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../components/glass_card.dart';

import '../../core/export_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

class AuditTrailScreen extends ConsumerWidget {
  const AuditTrailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audit Trail',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const Text(
                            'Historical financial operations',
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withOpacity(0.2)),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await ExportService.exportToExcel();
                          },
                          icon: const Icon(Icons.file_download_outlined, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', true),
                        const SizedBox(width: 8),
                        _filterChip('Contributions', false),
                        const SizedBox(width: 8),
                        _filterChip('Expenses', false),
                        const SizedBox(width: 8),
                        _filterChip('Cells', false),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  auditLogsAsync.when(
                    data: (logs) => Expanded(
                      child: ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final isExpense = log['action'] == 'EXPENSE_RECORDED';
                          return GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: (isExpense ? Colors.pink : Colors.teal).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                    color: isExpense ? Colors.pink : Colors.teal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log['action'].toString().replaceAll('_', ' '),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log['details'] ?? '',
                                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 12, color: Colors.white38),
                                          const SizedBox(width: 4),
                                          Text(log['performedBy'] ?? 'Unknown', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.access_time, size: 12, color: Colors.white38),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM dd, HH:mm').format(DateTime.parse(log['timestamp'])),
                                            style: const TextStyle(fontSize: 10, color: Colors.white38),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('Error loading audit trail: $e'),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.secondaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
