import 'package:flutter_test/flutter_test.dart';
import 'package:srf_finance/domain/models.dart';
import 'package:flutter/material.dart';

void main() {
  group('Domain Models Parsing', () {
    test('User.fromJson should parse correctly', () {
      final json = {
        'id': '1',
        'organizationId': 'org1',
        'name': 'Test User',
        'email': 'test@test.com',
        'role': 'ADMIN',
      };
      final user = User.fromJson(json);
      expect(user.id, '1');
      expect(user.role, UserRole.admin);
    });

    test('Cell.fromJson should parse correctly', () {
      final json = {
        'id': 'cell1',
        'organizationId': 'org1',
        'name': 'Logistics',
        'budget': 5000.0,
        'spent': 1000.0,
        'income': 200.0,
        'icon': 'local_shipping',
        'color': '#FF4500',
      };
      final cell = Cell.fromJson(json);
      expect(cell.name, 'Logistics');
      expect(cell.remaining, 4000.0);
      expect(cell.color.value, const Color(0xFFFF4500).value);
    });

    test('Contribution.fromJson should parse correctly', () {
      final json = {
        'id': 'c1',
        'organizationId': 'org1',
        'userId': 'u1',
        'amount': 3000.0,
        'date': DateTime.now().toIso8601String(),
        'user': {'name': 'Member 1'},
      };
      final contribution = Contribution.fromJson(json);
      expect(contribution.amount, 3000.0);
      expect(contribution.userName, 'Member 1');
    });

    test('Expense.fromJson should parse correctly', () {
      final json = {
        'id': 'e1',
        'organizationId': 'org1',
        'title': 'Paper',
        'amount': 50.0,
        'cellId': 'cell1',
        'date': DateTime.now().toIso8601String(),
        'performedBy': 'admin@test.com',
        'cell': {'name': 'Logistics'},
      };
      final expense = Expense.fromJson(json);
      expect(expense.title, 'Paper');
      expect(expense.cellName, 'Logistics');
    });
  });
}
