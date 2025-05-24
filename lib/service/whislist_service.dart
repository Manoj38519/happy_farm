import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static const String baseUrl='https://api.sabbafarm.com/api';
  static Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String? token = prefs.getString('token');final response = await http.get(
      Uri.parse('$baseUrl/api/my-list?userId=$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      if (result['success'] == true && result['data'] != null) {
        return List<Map<String, dynamic>>.from(result['data']);
      } else {
        throw Exception(result['message'] ?? 'No data found');
      }
    } else {
      throw Exception(result['message'] ?? 'Failed to load wishlist');
    }
  }

  static Future<bool> removeFromWishlist(String wishlistItemId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/my-list/$wishlistItemId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> addToCart({
    required String productId,
    required String priceId,
    required int quantity,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId == null) return false;

    final body = {
      "productId": productId,
      "priceId": priceId,
      "userId": userId,
      "quantity": quantity,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/cart/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token ?? "",
      },
      body: json.encode(body),
    );

    return response.statusCode == 201;
  }
}
