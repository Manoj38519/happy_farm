import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happy_farm/models/cart_model.dart';

class CartService {
  static const String baseUrl='https://api.sabbafarm.com/api';
  static Future<List<CartItem>> fetchCart(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse("$baseUrl/cart?userId=$userId");

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
      throw Exception('Failed to load cart data: ${response.statusCode}');
    }
  }

  static Future<bool> deleteCartItem(String cartItemId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/cart/$cartItemId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete cart item: ${response.statusCode}');
    }
  }
}
