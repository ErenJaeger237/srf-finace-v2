import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

class AddContributionForm extends ConsumerStatefulWidget {
  const AddContributionForm({super.key});

  @override
  ConsumerState<AddContributionForm> createState() => _AddContributionFormState();
}

class _AddContributionFormState extends ConsumerState<AddContributionForm> {
  String? selectedMemberId;
  final amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);

    return _BaseFormLayout(
      title: 'Add Contribution',
      icon: Icons.person_add_rounded,
      color: Colors.teal,
      isLoading: _isLoading,
      children: [
        membersAsync.when(
          data: (members) => _buildDropdown(
            label: 'Select Member',
            value: selectedMemberId,
            items: members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
            onChanged: (val) => setState(() => selectedMemberId = val),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: amountController,
          label: 'Amount (FCFA)',
          hint: 'e.g. 3000',
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () async {
        if (selectedMemberId == null || amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a member and enter an amount')));
          return;
        }
        setState(() => _isLoading = true);
        try {
          final success = await ref.read(apiServiceProvider).addContribution(
            selectedMemberId!,
            double.parse(amountController.text),
          );
          if (success) {
            ref.invalidate(contributionsProvider);
            if (context.mounted) {
               Navigator.pop(context);
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution added successfully')));
            }
          } else {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add contribution. Check permissions.')));
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }
}

class RecordExpenseForm extends ConsumerStatefulWidget {
  const RecordExpenseForm({super.key});

  @override
  ConsumerState<RecordExpenseForm> createState() => _RecordExpenseFormState();
}

class _RecordExpenseFormState extends ConsumerState<RecordExpenseForm> {
  String? selectedCellId;
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cellsAsync = ref.watch(cellsProvider);

    return _BaseFormLayout(
      title: 'Record Expense',
      icon: Icons.receipt_long_rounded,
      color: Colors.pink,
      isLoading: _isLoading,
      children: [
        _buildTextField(
          controller: titleController,
          label: 'Title',
          hint: 'e.g. Printer ink',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: amountController,
          label: 'Amount (FCFA)',
          hint: '0.00',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        cellsAsync.when(
          data: (cells) => _buildDropdown(
            label: 'Cell',
            value: selectedCellId,
            items: cells.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => selectedCellId = val),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
      onSave: () async {
        if (selectedCellId == null || titleController.text.isEmpty || amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
          return;
        }
        setState(() => _isLoading = true);
        try {
          final success = await ref.read(apiServiceProvider).recordExpense(
            titleController.text,
            double.parse(amountController.text),
            selectedCellId!,
          );
          if (success) {
            ref.invalidate(expensesProvider);
            ref.invalidate(cellsProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense recorded successfully')));
            }
          } else {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record expense')));
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }
}

class RecordIncomeForm extends ConsumerStatefulWidget {
  const RecordIncomeForm({super.key});

  @override
  ConsumerState<RecordIncomeForm> createState() => _RecordIncomeFormState();
}

class _RecordIncomeFormState extends ConsumerState<RecordIncomeForm> {
  String? selectedCellId;
  final amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cellsAsync = ref.watch(cellsProvider);

    return _BaseFormLayout(
      title: 'Record Cell Income',
      icon: Icons.trending_up_rounded,
      color: Colors.greenAccent,
      isLoading: _isLoading,
      children: [
        cellsAsync.when(
          data: (cells) => _buildDropdown(
            label: 'Source Cell',
            value: selectedCellId,
            items: cells.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => selectedCellId = val),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: amountController,
          label: 'Amount (FCFA)',
          hint: '0.00',
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () async {
        if (selectedCellId == null || amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a cell and enter an amount')));
          return;
        }
        setState(() => _isLoading = true);
        try {
          final success = await ref.read(apiServiceProvider).recordIncome(
            selectedCellId!,
            double.parse(amountController.text),
          );
          if (success) {
            ref.invalidate(cellsProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Income recorded successfully')));
            }
          } else {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record income')));
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }
}

class CreateCellForm extends ConsumerStatefulWidget {
  const CreateCellForm({super.key});

  @override
  ConsumerState<CreateCellForm> createState() => _CreateCellFormState();
}

class _CreateCellFormState extends ConsumerState<CreateCellForm> {
  final nameController = TextEditingController();
  final budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _BaseFormLayout(
      title: 'Create New Cell',
      icon: Icons.category_rounded,
      color: Colors.orange,
      isLoading: _isLoading,
      children: [
        _buildTextField(
          controller: nameController,
          label: 'Cell Name',
          hint: 'e.g. Logistics',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: budgetController,
          label: 'Initial Budget (FCFA)',
          hint: '10000',
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () async {
        if (nameController.text.isEmpty || budgetController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name and budget')));
          return;
        }
        setState(() => _isLoading = true);
        try {
          final success = await ref.read(apiServiceProvider).createCell(
            nameController.text,
            double.parse(budgetController.text),
          );
          if (success) {
            ref.invalidate(cellsProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New cell created successfully')));
            }
          } else {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create cell. Admin only?')));
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }
}

// Internal Helper Components
class _BaseFormLayout extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final VoidCallback onSave;
  final bool isLoading;

  const _BaseFormLayout({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
            ],
          ),
          const SizedBox(height: 32),
          ...children,
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Entry'),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType? keyboardType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ],
  );
}

Widget _buildDropdown<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required Function(T?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            hint: const Text('Select an option', style: TextStyle(color: Colors.white24, fontSize: 14)),
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
