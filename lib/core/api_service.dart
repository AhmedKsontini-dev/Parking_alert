import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Added for kIsWeb

class ApiService {
  // Use http://10.0.2.2:3000 for Android Emulator
  // Use http://localhost:3000 for iOS Simulator OR Web/Chrome
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:3000/api' 
      : 'http://10.0.2.2:3000/api';

  // 👤 Users
  static Future<Map<String, dynamic>?> getUser(String matricule) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$matricule'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      log('Error getting user: $e');
      return null;
    }
  }

  static Future<bool> registerUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      log('Error registering user: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      log('Error logging in: $e');
      return null;
    }
  }

  static Future<bool> updateUser(String matricule, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$matricule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Error updating user: $e');
      return false;
    }
  }

  // 🔔 Alerts
  static Future<bool> sendAlert(Map<String, dynamic> alertData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alerts/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alertData),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Error sending alert: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getAlerts(String matricule) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alerts/$matricule'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      log('Error getting alerts: $e');
      return [];
    }
  }

  static Future<bool> updateAlertStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Error updating alert status: $e');
      return false;
    }
  }
}
