import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:happy_farm/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String baseUrl = "https://api.sabbafarm.com"; // Use 10.0.2.2 for Android emulator

  static Future<List<CartItem>> fetchCart(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse("$baseUrl/api/cart?userId=$userId");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load cart data');
    }
  }
}
