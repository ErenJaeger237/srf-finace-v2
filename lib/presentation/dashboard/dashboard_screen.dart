import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../data/mock_repository.dart';
import '../components/glass_card.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);
  final compactFormat = NumberFormat.compact();

  @override
  Widget build(BuildContext context) {
    final cellsAsync = ref.watch(cellsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final contributionsAsync = ref.watch(contributionsProvider);
    final userRoleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(cellsProvider);
                ref.invalidate(expensesProvider);
                ref.invalidate(contributionsProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    
                    // Main Balance & Summary Grid (Aggregated from live data)
                    _buildLiveFinancialOverview(ref),
                    
                    const SizedBox(height: 24),

                    // Role-Based Visualization
                    userRoleAsync.when(
                      data: (role) => _buildRoleSpecificContent(role, ref),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    const SizedBox(height: 24),
                    const Text('Cell Budgets', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildLiveCellBudgets(cellsAsync),
                    
                    const SizedBox(height: 24),
                    _buildRecentTransactionsHeader(),
                    _buildLiveTransactionsList(expensesAsync, contributionsAsync),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFinancialOverview(WidgetRef ref) {
    final cells = ref.watch(cellsProvider).value ?? [];
    final contributions = ref.watch(contributionsProvider).value ?? [];
    
    final totalIncome = contributions.fold(0.0, (sum, item) => sum + item.amount) + 
                       cells.fold(0.0, (sum, item) => sum + item.income);
    final totalExpenses = ref.watch(expensesProvider).value?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;
    final balance = totalIncome - totalExpenses;

    return Column(
      children: [
        _buildBalanceCard(context, balance),
        const SizedBox(height: 16),
        _buildSummaryGrid(totalIncome, totalExpenses),
      ],
    );
  }

  Widget _buildRoleSpecificContent(UserRole role, WidgetRef ref) {
    if (role == UserRole.admin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Distribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildPieChart(context, ref.watch(cellsProvider).value ?? []),
          const SizedBox(height: 24),
          const Text('Income Comparison by Cell', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildIncomeBarChart(context, ref.watch(cellsProvider).value ?? []),
          const SizedBox(height: 24),
          const Text('Group Contributions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildContributionsBarChart(context, ref.watch(contributionsProvider).value ?? []),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Contribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildPersonalContributionCard(context),
        ],
      );
    }
  }

  Widget _buildLiveCellBudgets(AsyncValue<List<Cell>> cellsAsync) {
    return cellsAsync.when(
      data: (cells) => SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cells.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final cell = cells[index];
            return GlassCard(
              width: 160,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(cell.icon, color: cell.color, size: 24),
                const Spacer(),
                Text(cell.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: cell.percentage, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(cell.color), minHeight: 6)),
                const SizedBox(height: 8),
                Text('${compactFormat.format(cell.spent)} / ${compactFormat.format(cell.budget)}', style: const TextStyle(fontSize: 10, color: AppColors.secondaryText))
              ]),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildLiveTransactionsList(AsyncValue<List<Expense>> expenses, AsyncValue<List<Contribution>> contributions) {
    final List<dynamic> items = [...(expenses.value ?? []), ...(contributions.value ?? [])];
    items.sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length.clamp(0, 5),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Contribution) {
          return _buildTransactionItem(context, title: item.userName, subtitle: 'Contribution', amount: item.amount, isIncome: true, initials: item.userName.substring(0, 1), color: Colors.orange);
        } else {
          return _buildTransactionItem(context, title: item.title, subtitle: item.cellName, amount: item.amount, isIncome: false, initials: item.title.substring(0, 1), color: Colors.pink);
        }
      },
    );
  }

  // Refactored helpers for cleaner code
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning, Manager', style: Theme.of(context).textTheme.bodyMedium),
            Text('Financial Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder)),
          child: const Icon(Icons.notifications_outlined, size: 24),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Balance', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('+12.5%', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(MockRepository.availableBalance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 18), SizedBox(width: 4), Text('Add Funds')]))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.call_made_rounded, size: 18, color: Colors.white), SizedBox(width: 4), Text('Withdraw', style: TextStyle(color: Colors.white))]))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(child: GlassCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_wallet_outlined, size: 20)), const SizedBox(height: 12), const Text('Total Income', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)), Text('FCFA ${compactFormat.format(MockRepository.totalContributions)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]))),
        const SizedBox(width: 16),
        Expanded(child: GlassCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.secondary)), const SizedBox(height: 12), const Text('Expenses', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)), Text('FCFA ${compactFormat.format(MockRepository.totalExpenses)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]))),
      ],
    );
  }

  Widget _buildCellBudgetsList() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MockRepository.cells.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cell = MockRepository.cells[index];
          return GlassCard(
            width: 160,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(cell.icon, color: cell.color, size: 24), const Spacer(), Text(cell.name, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: cell.percentage, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(cell.color), minHeight: 6)), const SizedBox(height: 8), Text('${compactFormat.format(cell.spent)} / ${compactFormat.format(cell.budget)}', style: const TextStyle(fontSize: 10, color: AppColors.secondaryText))]),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: AppColors.secondaryText))),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MockRepository.recentContributions.length + MockRepository.recentExpenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < MockRepository.recentContributions.length) {
          final c = MockRepository.recentContributions[index];
          return _buildTransactionItem(context, title: c.userName, subtitle: 'Contribution', amount: c.amount, isIncome: true, initials: c.userName.substring(0, 1), color: Colors.orange);
        } else {
          final e = MockRepository.recentExpenses[index - MockRepository.recentContributions.length];
          return _buildTransactionItem(context, title: e.title, subtitle: e.cellName, amount: e.amount, isIncome: false, initials: e.title.substring(0, 1), color: Colors.pink);
        }
      },
    );
  }


  Widget _buildPieChart(BuildContext context) {
    return GlassCard(
      height: 240,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: MockRepository.cells.map((cell) {
                  return PieChartSectionData(
                    color: cell.color,
                    value: cell.spent,
                    title: '${(cell.spent / MockRepository.totalExpenses * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: MockRepository.cells.map((cell) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: cell.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cell.name,
                          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeBarChart(BuildContext context) {
    return GlassCard(
      height: 240,
      padding: const EdgeInsets.all(24),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < MockRepository.cells.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(MockRepository.cells[value.toInt()].name.substring(0, 3), style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: MockRepository.cells.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.income,
                  color: entry.value.color,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContributionsBarChart(BuildContext context) {
    return GlassCard(
      height: 240,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12, right: 12),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('M${value.toInt() + 1}', style: const TextStyle(fontSize: 9, color: AppColors.secondaryText));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(14, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: i < 12 ? 3000 : 0,
                  color: i < 12 ? Colors.teal : Colors.orange.withOpacity(0.3),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPersonalContributionCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Paid', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                  Text('FCFA 3,000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.tealAccent)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Text('STATUS: PAID', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.secondaryText),
              SizedBox(width: 8),
              Expanded(child: Text('Your next contribution is due on May 1st.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNav() {
    return GlassCard(
      borderRadius: 30,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, Icons.grid_view_rounded, 'Dashboard'),
          _navItem(1, Icons.group_rounded, 'Members'),
          _navItem(2, Icons.pie_chart_rounded, 'Budgets'),
          
          // Special "New Entry" FAB-style button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Text('New Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.secondaryText,
            size: 24,
          ),
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
}
