import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/sensor_data.dart';

/// Backend API service for session upload and reward claims
class ApiService {
  // Using ADB port forwarding (adb reverse tcp:3000 tcp:3000)
  // This makes localhost:3000 on phone connect to computer's port 3000
  static const String baseUrl = 'http://localhost:3000';
  
  // Custom HTTP client with longer timeout
  static http.Client? _client;
  static http.Client get client {
    if (_client == null) {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 10);
      httpClient.idleTimeout = const Duration(seconds: 15);
      _client = IOClient(httpClient);
    }
    return _client!;
  }

  /// Upload a completed session to the backend
  static Future<Map<String, dynamic>?> uploadSession({
    required String deviceId,
    required int startTime,
    required int endTime,
    required int totalSteps,
    required double totalDistance,
    required double avgCadence,
    required double caloriesBurned,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'start_time': startTime,
          'end_time': endTime,
          'total_steps': totalSteps,
          'total_distance': totalDistance,
          'avg_cadence': avgCadence,
          'calories_burned': caloriesBurned,
          'session_data': sessionData ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['session'];
      } else {
        print('Failed to upload session: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading session: $e');
      return null;
    }
  }

  /// Create a reward claim request
  static Future<Map<String, dynamic>?> createClaim({
    required int sessionId,
    required String userWallet,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/claims'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'user_wallet': userWallet,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        // Validation error (min steps, daily limit, etc.)
        final error = jsonDecode(response.body);
        print('Claim validation failed: ${error['error']}');
        return error;
      } else {
        print('Failed to create claim: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating claim: $e');
      return null;
    }
  }

  /// Get pending claims (for admin view)
  static Future<List<dynamic>?> getPendingClaims() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/claims/pending'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['claims'];
      }
      return null;
    } catch (e) {
      print('Error fetching pending claims: $e');
      return null;
    }
  }

  /// Get claims for a specific wallet
  static Future<List<dynamic>?> getWalletClaims(String walletAddress) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/claims/wallet/$walletAddress'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['claims'];
      }
      return null;
    } catch (e) {
      print('Error fetching wallet claims: $e');
      return null;
    }
  }

  /// Get wallet balance and stats
  static Future<Map<String, dynamic>?> getWalletInfo(
      String walletAddress) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/wallet/$walletAddress'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['wallet'];
      }
      return null;
    } catch (e) {
      print('Error fetching wallet info: $e');
      return null;
    }
  }

  /// Approve a claim (admin action - returns unsigned transaction)
  static Future<Map<String, dynamic>?> approveClaim(int claimId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/claims/$claimId/approve'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error approving claim: $e');
      return null;
    }
  }

  /// Complete a claim (submit signed transaction)
  static Future<Map<String, dynamic>?> completeClaim(
    int claimId,
    String signedTransaction,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/claims/$claimId/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'signedTransaction': signedTransaction,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error completing claim: $e');
      return null;
    }
  }

  /// Reject a claim (admin action)
  static Future<bool> rejectClaim(int claimId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/claims/$claimId/reject'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting claim: $e');
      return false;
    }
  }

  /// Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }
}

