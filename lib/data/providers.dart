import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../domain/models.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final cellsProvider = FutureProvider<List<Cell>>((ref) async {
  return ref.watch(apiServiceProvider).getCells();
});

final contributionsProvider = FutureProvider<List<Contribution>>((ref) async {
  return ref.watch(apiServiceProvider).getContributions();
});

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  return ref.watch(apiServiceProvider).getExpenses();
});

final auditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(apiServiceProvider).getAuditLogs();
});

final membersProvider = FutureProvider<List<User>>((ref) async {
  return ref.watch(apiServiceProvider).getMembers();
});

final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final role = await ref.watch(apiServiceProvider).storage.read(key: 'user_role');
  return role == 'ADMIN' ? UserRole.admin : UserRole.member;
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  return ref.watch(apiServiceProvider).storage.read(key: 'user_id');
});

final currentUserNameProvider = FutureProvider<String?>((ref) async {
  return ref.watch(apiServiceProvider).storage.read(key: 'user_name');
});
