import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../components/glass_card.dart';

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
    final userNameAsync = ref.watch(currentUserNameProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
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
                    _buildHeader(context, userNameAsync.value ?? 'Manager'),
                    const SizedBox(height: 24),
                    _buildLiveFinancialOverview(ref),
                    const SizedBox(height: 24),
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
    final expenses = ref.watch(expensesProvider).value ?? [];
    
    final totalIncome = contributions.fold(0.0, (sum, item) => sum + item.amount) + 
                       cells.fold(0.0, (sum, item) => sum + item.income);
    final totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
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
      final cells = ref.watch(cellsProvider).value ?? [];
      final contributions = ref.watch(contributionsProvider).value ?? [];
      final totalExpenses = ref.watch(expensesProvider).value?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Distribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildPieChart(context, cells, totalExpenses),
          const SizedBox(height: 24),
          const Text('Income Comparison by Cell', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildIncomeBarChart(context, cells),
          const SizedBox(height: 24),
          const Text('Group Contributions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildContributionsBarChart(context, contributions),
        ],
      );
    } else {
      final contributions = ref.watch(contributionsProvider).value ?? [];
      final userId = ref.watch(currentUserIdProvider).value;
      
      final myTotal = contributions
          .where((c) => c.userId == userId)
          .fold(0.0, (sum, item) => sum + item.amount);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Contribution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          _buildPersonalContributionCard(context, myTotal),
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
          separatorBuilder: (context, index) => const SizedBox(width: 16),
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
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is Contribution) {
          return _buildTransactionItem(context, title: item.userName, subtitle: 'Contribution', amount: item.amount, isIncome: true, initials: item.userName.isNotEmpty ? item.userName.substring(0, 1) : 'U', color: Colors.orange);
        } else {
          return _buildTransactionItem(context, title: item.title, subtitle: item.cellName, amount: item.amount, isIncome: false, initials: item.title.isNotEmpty ? item.title.substring(0, 1) : 'E', color: Colors.pink);
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Day, $name', style: Theme.of(context).textTheme.bodyMedium),
            Text('Financial Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, border: Border.all(color: AppColors.glassBorder)),
          child: const Icon(Icons.notifications_outlined, size: 24),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
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
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(balance),
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

  Widget _buildSummaryGrid(double income, double expenses) {
    return Row(
      children: [
        Expanded(child: GlassCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_wallet_outlined, size: 20)), const SizedBox(height: 12), const Text('Total Income', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)), Text('FCFA ${compactFormat.format(income)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]))),
        const SizedBox(width: 16),
        Expanded(child: GlassCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.secondary)), const SizedBox(height: 12), const Text('Expenses', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)), Text('FCFA ${compactFormat.format(expenses)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]))),
      ],
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

  Widget _buildPieChart(BuildContext context, List<Cell> cells, double totalExpenses) {
    if (totalExpenses == 0) {
       return const GlassCard(height: 240, child: Center(child: Text('No expenses recorded', style: TextStyle(color: AppColors.secondaryText))));
    }
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
                sections: cells.map((cell) {
                  return PieChartSectionData(
                    color: cell.color,
                    value: cell.spent,
                    title: cell.spent > 0 ? '${(cell.spent / totalExpenses * 100).toInt()}%' : '',
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
              children: cells.map((cell) {
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

  Widget _buildIncomeBarChart(BuildContext context, List<Cell> cells) {
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
                  if (value.toInt() < cells.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(cells[value.toInt()].name.substring(0, 3).toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: cells.asMap().entries.map((entry) {
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

  Widget _buildContributionsBarChart(BuildContext context, List<Contribution> contributions) {
    final Map<String, double> userTotals = {};
    for (var c in contributions) {
      userTotals[c.userName] = (userTotals[c.userName] ?? 0.0) + c.amount;
    }
    final sortedNames = userTotals.keys.toList()..sort();

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
                  if (value.toInt() < sortedNames.length) {
                    return Text(sortedNames[value.toInt()].substring(0, 1), style: const TextStyle(fontSize: 9, color: AppColors.secondaryText));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedNames.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: userTotals[entry.value]!,
                  color: Colors.teal,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPersonalContributionCard(BuildContext context, double myTotal) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Paid', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                  Text(currencyFormat.format(myTotal), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.tealAccent)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(myTotal > 0 ? 'STATUS: ACTIVE' : 'STATUS: PENDING', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10)),
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
              Expanded(child: Text('Your contributions help the organization grow.', style: TextStyle(color: AppColors.secondaryText, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required bool isIncome,
    required String initials,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${compactFormat.format(amount)}',
            style: TextStyle(fontWeight: FontWeight.w900, color: isIncome ? Colors.tealAccent : Colors.pinkAccent),
          ),
        ],
      ),
    );
  }
}
