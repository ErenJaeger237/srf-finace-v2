import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../components/glass_card.dart';
import 'dashboard_screen.dart';
import '../members/members_screen.dart';
import '../budgets/budgets_screen.dart';
import '../audit/audit_trail_screen.dart';

import '../components/entry_forms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MembersScreen(),
    const BudgetsScreen(),
    const AuditTrailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: GlassCard(
        borderRadius: 30,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(0, Icons.grid_view_rounded, 'Overview'),
            _navItem(1, Icons.group_rounded, 'Members'),
            _navItem(2, Icons.pie_chart_rounded, 'Budgets'),
            _navItem(3, Icons.history_rounded, 'Audit'),
            
            // FAB Style Action
            GestureDetector(
              onTap: () => _showNewEntryOptions(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.secondaryText,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewEntryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add New Entry',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 32),
            _actionTile(Icons.person_add_rounded, 'Add Contribution', Colors.teal, () {
              Navigator.pop(context);
              _showForm(context, const AddContributionForm());
            }),
            const SizedBox(height: 16),
            _actionTile(Icons.trending_up_rounded, 'Record Cell Income', Colors.greenAccent, () {
              Navigator.pop(context);
              _showForm(context, const RecordIncomeForm());
            }),
            const SizedBox(height: 16),
            _actionTile(Icons.receipt_long_rounded, 'Record Expense', Colors.pink, () {
              Navigator.pop(context);
              _showForm(context, const RecordExpenseForm());
            }),
            const SizedBox(height: 16),
            _actionTile(Icons.category_rounded, 'Create New Cell', Colors.orange, () {
              Navigator.pop(context);
              _showForm(context, const CreateCellForm());
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => form,
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
