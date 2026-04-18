import 'package:flutter/material.dart';

enum UserRole { admin, member }

class User {
  final String id;
  final String organizationId;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      organizationId: json['organizationId'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'ADMIN' ? UserRole.admin : UserRole.member,
    );
  }
}

class Contribution {
  final String id;
  final String organizationId;
  final String userId;
  final String userName;
  final double amount;
  final DateTime date;
  final bool isPaid;

  Contribution({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.date,
    this.isPaid = true,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      organizationId: json['organizationId'],
      userId: json['userId'],
      userName: json['user']?['name'] ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      isPaid: json['isPaid'] ?? true,
    );
  }
}

class Cell {
  final String id;
  final String organizationId;
  final String name;
  final double budget;
  final double spent;
  final double income;
  final IconData icon;
  final Color color;

  Cell({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.budget,
    this.spent = 0.0,
    this.income = 0.0,
    required this.icon,
    required this.color,
  });

  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      id: json['id'],
      organizationId: json['organizationId'],
      name: json['name'],
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num? ?? 0.0).toDouble(),
      income: (json['income'] as num? ?? 0.0).toDouble(),
      icon: _getIconData(json['icon']),
      color: _getColor(json['color']),
    );
  }

  static IconData _getIconData(String? name) {
    switch (name) {
      case 'local_shipping': return Icons.local_shipping_rounded;
      case 'campaign': return Icons.campaign_rounded;
      case 'security': return Icons.security_rounded;
      default: return Icons.category_rounded;
    }
  }

  static Color _getColor(String? hex) {
    if (hex == null) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  double get remaining => budget - spent;
  double get percentage => budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
}

class Expense {
  final String id;
  final String organizationId;
  final String title;
  final double amount;
  final String cellId;
  final String cellName;
  final DateTime date;
  final String performedBy;

  Expense({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.amount,
    required this.cellId,
    required this.cellName,
    required this.date,
    required this.performedBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      organizationId: json['organizationId'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      cellId: json['cellId'],
      cellName: json['cell']?['name'] ?? 'Unknown',
      date: DateTime.parse(json['date']),
      performedBy: json['performedBy'],
    );
  }
}
