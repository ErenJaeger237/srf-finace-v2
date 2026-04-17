import 'package:flutter/material.dart';
import '../domain/models.dart';

class MockRepository {
  static User currentUser = User(
    id: 'u1',
    organizationId: 'org1',
    name: 'A. Rodriguez',
    email: 'admin@streetride.org',
    role: UserRole.admin, // Change to UserRole.member to test member view
  );

  static final List<Cell> cells = [
    Cell(
      id: '1',
      organizationId: 'org1',
      name: 'Logistics',
      budget: 10000,
      spent: 8200,
      income: 5000,
      icon: Icons.local_shipping_rounded,
      color: Colors.orange,
    ),
    Cell(
      id: '2',
      organizationId: 'org1',
      name: 'Marketing',
      budget: 10000,
      spent: 4500,
      income: 12000,
      icon: Icons.campaign_rounded,
      color: Colors.pink,
    ),
    Cell(
      id: '3',
      organizationId: 'org1',
      name: 'Security',
      budget: 5000,
      spent: 1200,
      income: 1500,
      icon: Icons.security_rounded,
      color: Colors.teal,
    ),
  ];

  static final List<Expense> recentExpenses = [
    Expense(
      id: 'e1',
      organizationId: 'org1',
      title: 'Media Tools',
      amount: 450,
      cellId: '2',
      cellName: 'Marketing',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      performedBy: 'Finance Manager',
    ),
  ];

  static final List<Contribution> recentContributions = [
    Contribution(
      id: 'c1',
      organizationId: 'org1',
      userId: 'u1',
      userName: 'A. Rodriguez',
      amount: 1200,
      date: DateTime.now(),
    ),
    Contribution(
      id: 'c2',
      organizationId: 'org1',
      userId: 'u2',
      userName: 'J. Smith',
      amount: 250,
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static double get totalContributions => 42800;
  static double get totalExpenses => 18200;
  static double get availableBalance => 24560;
}
