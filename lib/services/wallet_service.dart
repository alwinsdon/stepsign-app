import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletService {
  static const String baseUrl = 'http://localhost:3000';

  /// Fetch wallet balance and stats
  static Future<Map<String, dynamic>> getWalletBalance(String walletAddress) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/$walletAddress'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'balance': data['balance'] ?? 0,
          'totalSteps': data['totalSteps'] ?? 0,
          'totalClaims': data['totalClaims'] ?? 0,
        };
      } else {
        return {'balance': 0, 'totalSteps': 0, 'totalClaims': 0};
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
      return {'balance': 0, 'totalSteps': 0, 'totalClaims': 0};
    }
  }
}
