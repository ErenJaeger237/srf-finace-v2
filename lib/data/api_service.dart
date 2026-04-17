import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000/api';
  final storage = const FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'jwt', value: data['token']);
      await storage.write(key: 'user_role', value: data['user']['role']);
      return data['token'];
    }
    return null;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Cell>> getCells() async {
    final response = await http.get(Uri.parse('$baseUrl/cells'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((c) => Cell.fromJson(c)).toList();
    }
    return [];
  }

  Future<List<Contribution>> getContributions() async {
    final response = await http.get(Uri.parse('$baseUrl/contributions'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((c) => Contribution.fromJson(c)).toList();
    }
    return [];
  }

  Future<List<Expense>> getExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<User>> getMembers() async {
    final response = await http.get(Uri.parse('$baseUrl/members'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((u) => User.fromJson(u)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/audit'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // POST / Actions
  Future<bool> addContribution(String userId, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contributions'),
      headers: await _getHeaders(),
      body: jsonEncode({'userId': userId, 'amount': amount}),
    );
    return response.statusCode == 201;
  }

  Future<bool> recordExpense(String title, double amount, String cellId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
      body: jsonEncode({'title': title, 'amount': amount, 'cellId': cellId}),
    );
    return response.statusCode == 201;
  }

  Future<bool> createCell(String name, double budget) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cells'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'budget': budget}),
    );
    return response.statusCode == 201;
  }

  Future<bool> recordIncome(String cellId, double amount) async {
    // Note: The backend route for updating income might need to be verified
    // Assuming PATCH /api/cells/:id with income update logic or a specific route
    final response = await http.patch(
      Uri.parse('$baseUrl/cells/$cellId'),
      headers: await _getHeaders(),
      body: jsonEncode({'income': amount}), // Simplification
    );
    return response.statusCode == 200;
  }
}
