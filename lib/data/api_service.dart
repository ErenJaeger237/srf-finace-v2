import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models.dart';

class ApiService {
  // Production URL: https://srf-finace-v2-1.onrender.com/api
  static String get _baseUrl {
    if (kReleaseMode) return 'https://srf-finace-v2-1.onrender.com/api';
    
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  final String baseUrl = _baseUrl;
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
      await storage.write(key: 'user_id', value: data['user']['id']);
      await storage.write(key: 'user_name', value: data['user']['name']);
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
    debugPrint('ApiService: Fetching Cells...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/cells'), headers: await _getHeaders());
      debugPrint('ApiService: Cells Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((c) => Cell.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('ApiService: Fetch Cells Error: $e');
    }
    return [];
  }

  Future<List<Contribution>> getContributions() async {
    debugPrint('ApiService: Fetching Contributions...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/contributions'), headers: await _getHeaders());
      debugPrint('ApiService: Contributions Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((c) => Contribution.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('ApiService: Fetch Contributions Error: $e');
    }
    return [];
  }

  Future<List<Expense>> getExpenses() async {
    debugPrint('ApiService: Fetching Expenses...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/expenses'), headers: await _getHeaders());
      debugPrint('ApiService: Expenses Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Expense.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService: Fetch Expenses Error: $e');
    }
    return [];
  }

  Future<List<User>> getMembers() async {
    debugPrint('ApiService: Fetching Members...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/members'), headers: await _getHeaders());
      debugPrint('ApiService: Members Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((u) => User.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint('ApiService: Fetch Members Error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    debugPrint('ApiService: Fetching Audit Logs...');
    try {
      final response = await http.get(Uri.parse('$baseUrl/audit'), headers: await _getHeaders());
      debugPrint('ApiService: Audit Response ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('ApiService: Fetch Audit Error: $e');
    }
    return [];
  }

  // POST / Actions
  Future<bool> addContribution(String userId, double amount) async {
    debugPrint('ApiService: Adding Contribution for $userId: $amount');
    final response = await http.post(
      Uri.parse('$baseUrl/contributions'),
      headers: await _getHeaders(),
      body: jsonEncode({'userId': userId, 'amount': amount}),
    );
    debugPrint('ApiService: Add Contribution Response ${response.statusCode}: ${response.body}');
    return response.statusCode == 201;
  }

  Future<bool> recordExpense(String title, double amount, String cellId) async {
    debugPrint('ApiService: Recording Expense for $cellId: $title - $amount');
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
      body: jsonEncode({'title': title, 'amount': amount, 'cellId': cellId}),
    );
    debugPrint('ApiService: Record Expense Response ${response.statusCode}: ${response.body}');
    return response.statusCode == 201;
  }

  Future<bool> createCell(String name, double budget) async {
    debugPrint('ApiService: Creating Cell: $name - $budget');
    final response = await http.post(
      Uri.parse('$baseUrl/cells'),
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'budget': budget}),
    );
    debugPrint('ApiService: Create Cell Response ${response.statusCode}: ${response.body}');
    return response.statusCode == 201;
  }

  Future<bool> recordIncome(String cellId, double amount) async {
    debugPrint('ApiService: Recording Income for $cellId: $amount');
    final response = await http.post(
      Uri.parse('$baseUrl/cells/$cellId/income'),
      headers: await _getHeaders(),
      body: jsonEncode({'amount': amount}),
    );
    debugPrint('ApiService: Record Income Response ${response.statusCode}: ${response.body}');
    return response.statusCode == 200;
  }
}
